"""
Phase 2 -- inventory only, no downloads.

Walks every course, enumerates courseWork / courseWorkMaterials /
announcements, and resolves every Drive-file attachment to its id, name,
mimeType and size via the Drive API. Writes inventory.json, then prints
summary stats.

API references (method names, params, response schemas) were confirmed
against the live Classroom v1 and Drive v3 discovery documents:
  https://classroom.googleapis.com/$discovery/rest?version=v1
  https://www.googleapis.com/discovery/v1/apis/drive/v3/rest
and cross-checked against:
  https://developers.google.com/classroom/reference/rest/v1/courses.courseWork/list
  https://developers.google.com/classroom/reference/rest/v1/courses.courseWorkMaterials/list
  https://developers.google.com/classroom/reference/rest/v1/courses.announcements/list
  https://developers.google.com/drive/api/reference/rest/v3/files/get
  https://developers.google.com/drive/api/guides/mime-types
"""

import json
import os

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from auth import get_credentials

TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
INVENTORY_PATH = os.path.join(TOOL_DIR, "inventory.json")

NUM_RETRIES = 5  # google-api-python-client's built-in randomized exponential backoff

# https://developers.google.com/drive/api/guides/mime-types
NATIVE_GOOGLE_MIME_PREFIX = "application/vnd.google-apps."

# User-requested exclusions -- courses that should be skipped entirely,
# not just filtered downstream. "CS2005 Database Systems Fall 2025 (CY)":
# not needed, and courseWork.list already 403s on it (no permission).
EXCLUDED_COURSE_IDS = {"791793977887"}


def list_all(request_factory, list_kwargs, item_key):
    """Page through a Classroom list endpoint, returning all items."""
    items = []
    page_token = None
    while True:
        kwargs = dict(list_kwargs)
        if page_token:
            kwargs["pageToken"] = page_token
        response = request_factory(**kwargs).execute(num_retries=NUM_RETRIES)
        items.extend(response.get(item_key, []))
        page_token = response.get("nextPageToken")
        if not page_token:
            break
    return items


def extract_materials(materials, drive_files, drive_service, failures, context):
    """
    Normalize a materials[] array (from CourseWork / CourseWorkMaterial /
    Announcement) into lightweight references, resolving driveFile
    attachments against the Drive API and caching results in drive_files.

    Material schema confirmed via discovery doc: union of driveFile
    (SharedDriveFile -> DriveFile{id,title,alternateLink,thumbnailUrl}),
    youtubeVideo{id,title,alternateLink,thumbnailUrl}, link{url,title,
    thumbnailUrl}, form{formUrl,title,responseUrl,thumbnailUrl},
    notebook, gem. Only driveFile carries a resolvable Drive file id;
    DriveFile itself has no mimeType/size, hence the separate files.get
    call.
    """
    refs = []
    for material in materials or []:
        if "driveFile" in material:
            shared = material["driveFile"]
            drive_file = shared.get("driveFile", {})
            file_id = drive_file.get("id")
            refs.append(
                {
                    "type": "driveFile",
                    "fileId": file_id,
                    "shareMode": shared.get("shareMode"),
                }
            )
            if file_id and file_id not in drive_files:
                drive_files[file_id] = resolve_drive_file(
                    drive_service, file_id, failures, context
                )
        elif "youtubeVideo" in material:
            yt = material["youtubeVideo"]
            refs.append(
                {
                    "type": "youtubeVideo",
                    "id": yt.get("id"),
                    "title": yt.get("title"),
                    "alternateLink": yt.get("alternateLink"),
                }
            )
        elif "link" in material:
            link = material["link"]
            refs.append(
                {
                    "type": "link",
                    "url": link.get("url"),
                    "title": link.get("title"),
                }
            )
        elif "form" in material:
            form = material["form"]
            # Form has no `id` field in the Classroom API schema, so it
            # cannot be resolved via Drive files.get without parsing an
            # undocumented URL shape. Left unresolved deliberately.
            refs.append(
                {
                    "type": "form",
                    "formUrl": form.get("formUrl"),
                    "title": form.get("title"),
                }
            )
        else:
            # notebook / gem (NotebookLM, Gemini Gem) -- not Drive files.
            refs.append({"type": "other", "raw": material})
    return refs


def resolve_drive_file(drive_service, file_id, failures, context):
    """
    files.get confirmed at:
    https://developers.google.com/drive/api/reference/rest/v3/files/get
    supportsAllDrives=True included since course materials may live in a
    Shared Drive owned by the instructor.
    """
    try:
        return (
            drive_service.files()
            .get(
                fileId=file_id,
                fields="id,name,mimeType,size,trashed,md5Checksum",
                supportsAllDrives=True,
            )
            .execute(num_retries=NUM_RETRIES)
        )
    except HttpError as err:
        failures.append(
            {
                "context": context,
                "fileId": file_id,
                "error": str(err),
            }
        )
        return {"id": file_id, "error": str(err)}


def main():
    creds = get_credentials()
    classroom = build("classroom", "v1", credentials=creds)
    drive = build("drive", "v3", credentials=creds)

    drive_files = {}
    failures = []
    courses_out = []

    # courses.list: no courseStates filter -> "Courses in any state are
    # returned" per the discovery doc, so archived/past courses are
    # included.
    courses = list_all(classroom.courses().list, {"pageSize": 100}, "courses")
    print(f"Found {len(courses)} courses. Enumerating coursework...\n")

    for course in courses:
        course_id = course["id"]
        course_name = course.get("name")

        if course_id in EXCLUDED_COURSE_IDS:
            print(f"- {course_name} ({course_id}) -- SKIPPED (excluded)")
            continue

        print(f"- {course_name} ({course_id})")

        course_record = {
            "id": course_id,
            "name": course_name,
            "section": course.get("section"),
            "courseState": course.get("courseState"),
            "creationTime": course.get("creationTime"),
            "updateTime": course.get("updateTime"),
            "courseWork": [],
            "courseWorkMaterials": [],
            "announcements": [],
        }

        try:
            course_work = list_all(
                classroom.courses().courseWork().list,
                {"courseId": course_id, "pageSize": 100},
                "courseWork",
            )
        except HttpError as err:
            failures.append({"context": f"courseWork.list {course_id}", "error": str(err)})
            course_work = []

        for cw in course_work:
            course_record["courseWork"].append(
                {
                    "id": cw.get("id"),
                    "title": cw.get("title"),
                    "description": cw.get("description"),
                    "state": cw.get("state"),
                    "workType": cw.get("workType"),
                    "alternateLink": cw.get("alternateLink"),
                    "creationTime": cw.get("creationTime"),
                    "updateTime": cw.get("updateTime"),
                    "dueDate": cw.get("dueDate"),
                    "dueTime": cw.get("dueTime"),
                    "materials": extract_materials(
                        cw.get("materials"), drive_files, drive,
                        failures, f"courseWork {course_id}/{cw.get('id')}",
                    ),
                }
            )

        try:
            # Response field is "courseWorkMaterial" (singular), per the
            # live discovery doc -- confirmed directly, not assumed.
            cw_materials = list_all(
                classroom.courses().courseWorkMaterials().list,
                {"courseId": course_id, "pageSize": 100},
                "courseWorkMaterial",
            )
        except HttpError as err:
            failures.append({"context": f"courseWorkMaterials.list {course_id}", "error": str(err)})
            cw_materials = []

        for cwm in cw_materials:
            course_record["courseWorkMaterials"].append(
                {
                    "id": cwm.get("id"),
                    "title": cwm.get("title"),
                    "description": cwm.get("description"),
                    "state": cwm.get("state"),
                    "alternateLink": cwm.get("alternateLink"),
                    "creationTime": cwm.get("creationTime"),
                    "updateTime": cwm.get("updateTime"),
                    "materials": extract_materials(
                        cwm.get("materials"), drive_files, drive,
                        failures, f"courseWorkMaterial {course_id}/{cwm.get('id')}",
                    ),
                }
            )

        try:
            announcements = list_all(
                classroom.courses().announcements().list,
                {"courseId": course_id, "pageSize": 100},
                "announcements",
            )
        except HttpError as err:
            failures.append({"context": f"announcements.list {course_id}", "error": str(err)})
            announcements = []

        for ann in announcements:
            course_record["announcements"].append(
                {
                    "id": ann.get("id"),
                    "text": ann.get("text"),
                    "state": ann.get("state"),
                    "alternateLink": ann.get("alternateLink"),
                    "creationTime": ann.get("creationTime"),
                    "updateTime": ann.get("updateTime"),
                    "materials": extract_materials(
                        ann.get("materials"), drive_files, drive,
                        failures, f"announcement {course_id}/{ann.get('id')}",
                    ),
                }
            )

        courses_out.append(course_record)

    inventory = {
        "courses": courses_out,
        "driveFiles": drive_files,
        "failures": failures,
    }

    with open(INVENTORY_PATH, "w", encoding="utf-8") as f:
        json.dump(inventory, f, indent=2, ensure_ascii=False)

    print(f"\nWrote {INVENTORY_PATH}")
    print_report(drive_files, failures)


def print_report(drive_files, failures):
    resolved = [f for f in drive_files.values() if "error" not in f]
    unresolved = [f for f in drive_files.values() if "error" in f]

    total_files = len(drive_files)
    native = [
        f for f in resolved
        if (f.get("mimeType") or "").startswith(NATIVE_GOOGLE_MIME_PREFIX)
    ]

    sized = [f for f in resolved if f.get("size") is not None]
    total_bytes = sum(int(f["size"]) for f in sized)

    largest = sorted(sized, key=lambda f: int(f["size"]), reverse=True)[:10]

    print("\n" + "=" * 60)
    print("PHASE 2 INVENTORY REPORT")
    print("=" * 60)
    print(f"Distinct Drive files referenced: {total_files}")
    print(f"  resolved:                      {len(resolved)}")
    print(f"  failed to resolve:             {len(unresolved)}")
    print(f"Native Google format files:      {len(native)}")
    print(f"Files with a known size:         {len(sized)}")
    print(f"Total bytes (known-size files):  {total_bytes:,} ({total_bytes / (1024**3):.2f} GiB)")
    print(f"\nLargest 10 files:")
    for f in largest:
        size_mb = int(f["size"]) / (1024**2)
        print(f"  {size_mb:10.2f} MiB  {f.get('mimeType', '?'):45s}  {f.get('name')}")

    if unresolved:
        print(f"\n{len(unresolved)} files failed to resolve -- see failures[] in inventory.json")
    if failures:
        print(f"{len(failures)} total logged failures (list calls + file resolution).")


if __name__ == "__main__":
    main()
