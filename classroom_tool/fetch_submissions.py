"""
Patches a gap in Phase 2/4: the original inventory only enumerated what
teachers posted (courseWork / courseWorkMaterials / announcements). It
never pulled the student's own submitted work, so Phase 4 never
downloaded it. This script fetches courses.courseWork.studentSubmissions
and attaches resolved submission data onto the matching courseWork entry
in inventory.json, so download.py can pick it up on the next run.

API references confirmed against the live Classroom v1 discovery
document (https://classroom.googleapis.com/$discovery/rest?version=v1):

  - courses.courseWork.studentSubmissions.list
    path: v1/courses/{courseId}/courseWork/{courseWorkId}/studentSubmissions
    courseWorkId="-" fetches submissions for ALL courseWork in the course
    in a single call, instead of one call per assignment.
    Accepted scopes include classroom.coursework.me, which we already
    hold -- no re-auth needed (verified by reading the discovery doc's
    'scopes' list for this method directly, not assumed).

  - StudentSubmission.assignmentSubmission.attachments is an array of
    Attachment, which is a DIFFERENT schema from Material (used by
    courseWork/courseWorkMaterials/announcements in Phase 2):
      Attachment { driveFile: DriveFile (direct reference, NOT wrapped
                   in SharedDriveFile like Material.driveFile is),
                   youTubeVideo (capital T, capital V -- distinct
                   casing from Material's "youtubeVideo"), link, form }
    Confirmed by reading both schemas directly out of the discovery doc.
"""

import json

from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from auth import get_credentials
from inventory import resolve_drive_file, NUM_RETRIES, INVENTORY_PATH


def extract_attachments(attachments, drive_files, drive_service, failures, context):
    """Mirrors inventory.py's extract_materials, but for the Attachment
    schema (submission-side), not Material (teacher-posted-side)."""
    refs = []
    for a in attachments or []:
        if "driveFile" in a:
            drive_file = a["driveFile"]  # direct DriveFile, no SharedDriveFile wrapper
            file_id = drive_file.get("id")
            refs.append({"type": "driveFile", "fileId": file_id})
            if file_id and file_id not in drive_files:
                drive_files[file_id] = resolve_drive_file(drive_service, file_id, failures, context)
        elif "youTubeVideo" in a:
            yt = a["youTubeVideo"]
            refs.append({
                "type": "youtubeVideo",
                "id": yt.get("id"),
                "title": yt.get("title"),
                "alternateLink": yt.get("alternateLink"),
            })
        elif "link" in a:
            link = a["link"]
            refs.append({"type": "link", "url": link.get("url"), "title": link.get("title")})
        elif "form" in a:
            form = a["form"]
            refs.append({"type": "form", "formUrl": form.get("formUrl"), "title": form.get("title")})
        else:
            refs.append({"type": "other", "raw": a})
    return refs


def list_all_submissions(classroom, course_id):
    items = []
    page_token = None
    while True:
        kwargs = {"courseId": course_id, "courseWorkId": "-", "userId": "me", "pageSize": 100}
        if page_token:
            kwargs["pageToken"] = page_token
        resp = (
            classroom.courses().courseWork().studentSubmissions()
            .list(**kwargs).execute(num_retries=NUM_RETRIES)
        )
        items.extend(resp.get("studentSubmissions", []))
        page_token = resp.get("nextPageToken")
        if not page_token:
            break
    return items


def main():
    creds = get_credentials()
    classroom = build("classroom", "v1", credentials=creds)
    drive = build("drive", "v3", credentials=creds)

    with open(INVENTORY_PATH, "r", encoding="utf-8") as f:
        inventory = json.load(f)

    drive_files = inventory["driveFiles"]
    failures = inventory.setdefault("failures", [])

    cw_by_id = {}
    for c in inventory["courses"]:
        for cw in c["courseWork"]:
            cw_by_id[(c["id"], cw["id"])] = cw

    total_submissions = 0
    total_with_attachments = 0

    for course in inventory["courses"]:
        course_id = course["id"]
        try:
            submissions = list_all_submissions(classroom, course_id)
        except HttpError as err:
            failures.append({"context": f"studentSubmissions.list {course_id}", "error": str(err)})
            print(f"- {course.get('name')}: FAILED ({err})")
            continue

        print(f"- {course.get('name')}: {len(submissions)} submissions")

        for sub in submissions:
            cw_id = sub.get("courseWorkId")
            cw = cw_by_id.get((course_id, cw_id))
            if cw is None:
                continue

            total_submissions += 1
            context = f"submission {course_id}/{cw_id}/{sub.get('id')}"

            attachments = []
            assignment_submission = sub.get("assignmentSubmission")
            if assignment_submission:
                attachments = extract_attachments(
                    assignment_submission.get("attachments"), drive_files, drive, failures, context
                )
            if attachments:
                total_with_attachments += 1

            cw["mySubmission"] = {
                "id": sub.get("id"),
                "state": sub.get("state"),
                "late": sub.get("late"),
                "assignedGrade": sub.get("assignedGrade"),
                "creationTime": sub.get("creationTime"),
                "updateTime": sub.get("updateTime"),
                "alternateLink": sub.get("alternateLink"),
                "attachments": attachments,
                "shortAnswer": (sub.get("shortAnswerSubmission") or {}).get("answer"),
                "multipleChoiceAnswer": (sub.get("multipleChoiceSubmission") or {}).get("answer"),
            }

    with open(INVENTORY_PATH, "w", encoding="utf-8") as f:
        json.dump(inventory, f, indent=2, ensure_ascii=False)

    print(f"\n{total_submissions} submissions found, {total_with_attachments} with attachments.")
    print(f"Updated {INVENTORY_PATH}")


if __name__ == "__main__":
    main()
