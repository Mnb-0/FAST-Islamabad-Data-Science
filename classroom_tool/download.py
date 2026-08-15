"""
Phase 4 -- download, organize, export. Reads courses.yaml + inventory.json
(built in Phases 2-3) and materializes:

  <root>/<semester>/<course-code>/{assignments,materials,announcements}/

No new Classroom API calls are made here -- courseWork/courseWorkMaterials
/announcements metadata was already captured in inventory.json. Only the
Drive API is called, to fetch actual file bytes.

API references confirmed before writing this:
  - files.get(alt=media) via get_media() + MediaIoBaseDownload:
    https://developers.google.com/drive/api/guides/manage-downloads
    https://developers.google.com/drive/api/reference/rest/v3/files/get
  - files.export(mimeType=...) via export_media() + MediaIoBaseDownload:
    https://developers.google.com/drive/api/reference/rest/v3/files/export
    (10 MB export size limit, confirmed on that page)
  - PDF is a valid export target for document/spreadsheet/presentation/
    drawing; Forms have NO export target and no Drive file id in the
    Classroom Material schema (confirmed in Phase 2), so they cannot be
    downloaded at all -- only linked in the README:
    https://developers.google.com/drive/api/guides/ref-export-formats
  - MediaIoBaseDownload.next_chunk(num_retries=N) implements the same
    randomized exponential backoff as HttpRequest.execute(num_retries=N):
    https://googleapis.github.io/google-api-python-client/docs/epy/googleapiclient.http.MediaIoBaseDownload-class.html
  - CourseWork.dueDate / dueTime schemas (Date{year,month,day},
    TimeOfDay{hours,minutes,seconds,nanos}) confirmed against the live
    Classroom v1 discovery document.
"""

import json
import os
import re

import yaml
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaIoBaseDownload

from auth import get_credentials

TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(TOOL_DIR)
COURSES_YAML_PATH = os.path.join(TOOL_DIR, "courses.yaml")
INVENTORY_PATH = os.path.join(TOOL_DIR, "inventory.json")
FAILURES_LOG_PATH = os.path.join(TOOL_DIR, "download_failures.log")

NUM_RETRIES = 5

# https://developers.google.com/drive/api/guides/ref-export-formats
EXPORTABLE_TO_PDF = {
    "application/vnd.google-apps.document",
    "application/vnd.google-apps.spreadsheet",
    "application/vnd.google-apps.presentation",
    "application/vnd.google-apps.drawing",
}
NATIVE_PREFIX = "application/vnd.google-apps."

INVALID_CHARS = re.compile(r'[<>:"/\\|?*\x00-\x1f]')
RESERVED_NAMES = (
    {"CON", "PRN", "AUX", "NUL"}
    | {f"COM{i}" for i in range(1, 10)}
    | {f"LPT{i}" for i in range(1, 10)}
)


def sanitize_filename(name, max_len=120):
    """Windows-safe filename: strip illegal chars, trailing dot/space,
    dodge reserved device names, cap length while preserving extension."""
    name = (name or "untitled").strip()
    name = INVALID_CHARS.sub("_", name)
    name = name.rstrip(" .")
    if not name:
        name = "untitled"

    stem, dot, ext = name.rpartition(".")
    check = (stem if dot else name).upper()
    if check in RESERVED_NAMES:
        name = "_" + name

    if len(name) > max_len:
        stem, dot, ext = name.rpartition(".")
        if dot and len(ext) <= 10:
            name = stem[: max_len - len(ext) - 1] + "." + ext
        else:
            name = name[:max_len]
    return name


def slugify(text, max_len=60):
    text = (text or "untitled").lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    text = re.sub(r"[\s_]+", "-", text).strip("-")
    return text[:max_len].strip("-") or "untitled"


def format_due(due_date, due_time):
    if not due_date:
        return None
    y, m, d = due_date.get("year"), due_date.get("month"), due_date.get("day")
    s = f"{y:04d}-{m:02d}-{d:02d}"
    if due_time and due_time.get("hours") is not None:
        h = due_time.get("hours", 0)
        mi = due_time.get("minutes", 0)
        s += f" {h:02d}:{mi:02d} UTC"
    return s


def ensure_dirs(*paths):
    for p in paths:
        os.makedirs(p, exist_ok=True)


def plan_material_downloads(materials, drive_files):
    """
    For a materials[] list (already normalized in Phase 2 -- see
    inventory.py's extract_materials), decide what to do with each entry.
    Returns (downloadable_plans, unsupported_notes, external_links).
    Filename collisions within the same item are resolved by suffixing
    ALL colliding entries with their fileId (deterministic regardless of
    processing order -- doesn't matter who "got there first").
    """
    plans = []
    unsupported = []
    links = []

    for m in materials or []:
        t = m.get("type")
        if t == "driveFile":
            file_id = m.get("fileId")
            meta = drive_files.get(file_id) if file_id else None
            if not meta or "error" in meta:
                unsupported.append(f"driveFile {file_id}: unresolved in inventory (see Phase 2 failures)")
                continue
            mime = meta.get("mimeType", "")
            name = meta.get("name") or file_id
            if mime in EXPORTABLE_TO_PDF:
                stem = os.path.splitext(name)[0] or name
                filename = sanitize_filename(stem) + ".pdf"
                plans.append({
                    "mode": "export", "export_mime": "application/pdf",
                    "filename": filename, "fileId": file_id,
                    "expected_size": None,
                })
            elif mime.startswith(NATIVE_PREFIX):
                unsupported.append(f"{name}: native type {mime} has no PDF export target")
            else:
                filename = sanitize_filename(name)
                size = meta.get("size")
                plans.append({
                    "mode": "binary", "filename": filename, "fileId": file_id,
                    "expected_size": int(size) if size is not None else None,
                })
        elif t == "youtubeVideo":
            links.append(f"YouTube: {m.get('title') or m.get('id')} -- {m.get('alternateLink')}")
        elif t == "link":
            links.append(f"Link: {m.get('title') or m.get('url')} -- {m.get('url')}")
        elif t == "form":
            links.append(f"Google Form: {m.get('title')} -- {m.get('formUrl')}")
        else:
            links.append(f"Other material: {json.dumps(m.get('raw'))[:120]}")

    # Deterministic dedupe: group by sanitized filename, suffix every
    # member of any group with size > 1.
    by_name = {}
    for p in plans:
        by_name.setdefault(p["filename"], []).append(p)
    for name, group in by_name.items():
        if len(group) > 1:
            for p in group:
                stem, dot, ext = p["filename"].rpartition(".")
                suffix = p["fileId"][:8]
                p["filename"] = f"{stem}__{suffix}.{ext}" if dot else f"{p['filename']}__{suffix}"

    return plans, unsupported, links


def download_one(drive, plan, dest_dir, failures, context):
    dest_path = os.path.join(dest_dir, plan["filename"])

    # Idempotent resume: binaries verify against known Drive size;
    # exports can't know the rendered PDF's size ahead of time, so we
    # accept "exists and non-empty" as already-downloaded.
    if os.path.exists(dest_path):
        if plan["mode"] == "binary" and plan["expected_size"] is not None:
            if os.path.getsize(dest_path) == plan["expected_size"]:
                return "skipped"
        elif os.path.getsize(dest_path) > 0:
            return "skipped"

    tmp_path = dest_path + ".part"
    try:
        if plan["mode"] == "export":
            request = drive.files().export_media(fileId=plan["fileId"], mimeType=plan["export_mime"])
        else:
            request = drive.files().get_media(fileId=plan["fileId"], supportsAllDrives=True)

        with open(tmp_path, "wb") as fh:
            downloader = MediaIoBaseDownload(fh, request)
            done = False
            while not done:
                _, done = downloader.next_chunk(num_retries=NUM_RETRIES)
        os.replace(tmp_path, dest_path)
        return "downloaded"
    except HttpError as err:
        failures.append({"context": context, "fileId": plan["fileId"], "filename": plan["filename"], "error": str(err)})
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        return "failed"
    except OSError as err:
        failures.append({"context": context, "fileId": plan["fileId"], "filename": plan["filename"], "error": f"OSError: {err}"})
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        return "failed"


def process_item(drive, item, materials_key, drive_files, item_dir, failures, context, counts):
    plans, unsupported, links = plan_material_downloads(item.get(materials_key, []), drive_files)
    if plans:
        # Only create a directory when there's actually a file to put in
        # it -- otherwise text-only announcements/assignments (the
        # majority) litter the tree with empty folders.
        ensure_dirs(item_dir)
        for plan in plans:
            result = download_one(drive, plan, item_dir, failures, context)
            counts[result] += 1
    return unsupported, links


def build_readme(course_name, course_id, section, sections):
    lines = [f"# {course_name}", "", f"- Classroom course id: `{course_id}`"]
    if section:
        lines.append(f"- Section: {section}")
    lines.append("")
    for title, items in sections:
        lines.append(f"## {title}")
        lines.append("")
        if not items:
            lines.append("_None._")
            lines.append("")
            continue
        for it in items:
            lines.append(f"### {it['title']}")
            if it.get("due"):
                lines.append(f"- Due: {it['due']}")
            if it.get("state"):
                lines.append(f"- State: {it['state']}")
            if it.get("description"):
                lines.append("")
                lines.append(it["description"])
            if it.get("links"):
                lines.append("")
                lines.append("External / unsupported materials:")
                for l in it["links"]:
                    lines.append(f"- {l}")
            if it.get("unsupported"):
                lines.append("")
                lines.append("Not downloadable:")
                for u in it["unsupported"]:
                    lines.append(f"- {u}")
            sub = it.get("submission")
            if sub:
                lines.append("")
                lines.append("**My submission** (see `my-submission/`):")
                lines.append(f"- State: {sub.get('state')}")
                if sub.get("late"):
                    lines.append("- Late: yes")
                if sub.get("grade") is not None:
                    lines.append(f"- Grade: {sub['grade']}")
                if sub.get("shortAnswer"):
                    lines.append(f"- My answer: {sub['shortAnswer']}")
                if sub.get("multipleChoiceAnswer"):
                    lines.append(f"- My answer: {sub['multipleChoiceAnswer']}")
                for l in sub.get("links") or []:
                    lines.append(f"- {l}")
                for u in sub.get("unsupported") or []:
                    lines.append(f"- Not downloadable: {u}")
            lines.append("")
    return "\n".join(lines)


def main():
    creds = get_credentials()
    drive = build("drive", "v3", credentials=creds)

    with open(COURSES_YAML_PATH, "r", encoding="utf-8") as f:
        course_map = yaml.safe_load(f)["courses"]
    with open(INVENTORY_PATH, "r", encoding="utf-8") as f:
        inventory = json.load(f)

    drive_files = inventory["driveFiles"]
    inventory_by_id = {c["id"]: c for c in inventory["courses"]}

    failures = []
    counts = {"downloaded": 0, "skipped": 0, "failed": 0}
    unsupported_total = 0

    for course_id, mapping in course_map.items():
        course = inventory_by_id.get(course_id)
        if not course:
            print(f"WARNING: {course_id} in courses.yaml but not in inventory.json -- skipping")
            continue

        semester = mapping["semester"]
        code = mapping["course_code"]
        base = os.path.join(ROOT_DIR, semester, code)
        assignments_dir = os.path.join(base, "assignments")
        materials_dir = os.path.join(base, "materials")
        announcements_dir = os.path.join(base, "announcements")
        ensure_dirs(base, assignments_dir, materials_dir, announcements_dir)

        print(f"[{semester}/{code}] {mapping['name']}")

        readme_assignments = []
        for cw in course.get("courseWork", []):
            item_dir = os.path.join(assignments_dir, slugify(cw.get("title"))[:60] + "-" + (cw.get("id") or "")[-6:])
            context = f"{semester}/{code} assignment '{cw.get('title')}' ({cw.get('id')})"
            unsupported, links = process_item(drive, cw, "materials", drive_files, item_dir, failures, context, counts)
            unsupported_total += len(unsupported)

            # My own submission for this assignment (fetch_submissions.py
            # patches this onto inventory.json separately from the Phase
            # 2 teacher-posted materials -- see that script's docstring
            # for why this exists as an add-on rather than being folded
            # into inventory.py).
            submission = cw.get("mySubmission")
            sub_summary = None
            if submission:
                sub_dir = os.path.join(item_dir, "my-submission")
                sub_unsupported, sub_links = process_item(
                    drive, submission, "attachments", drive_files, sub_dir,
                    failures, context + " [my submission]", counts,
                )
                unsupported_total += len(sub_unsupported)
                sub_summary = {
                    "state": submission.get("state"),
                    "late": submission.get("late"),
                    "grade": submission.get("assignedGrade"),
                    "shortAnswer": submission.get("shortAnswer"),
                    "multipleChoiceAnswer": submission.get("multipleChoiceAnswer"),
                    "unsupported": sub_unsupported,
                    "links": sub_links,
                }

            readme_assignments.append({
                "title": cw.get("title") or "(untitled)",
                "due": format_due(cw.get("dueDate"), cw.get("dueTime")),
                "state": cw.get("state"),
                "description": cw.get("description"),
                "links": links,
                "unsupported": unsupported,
                "submission": sub_summary,
            })

        readme_materials = []
        for cwm in course.get("courseWorkMaterials", []):
            item_dir = os.path.join(materials_dir, slugify(cwm.get("title"))[:60] + "-" + (cwm.get("id") or "")[-6:])
            context = f"{semester}/{code} material '{cwm.get('title')}' ({cwm.get('id')})"
            unsupported, links = process_item(drive, cwm, "materials", drive_files, item_dir, failures, context, counts)
            unsupported_total += len(unsupported)
            readme_materials.append({
                "title": cwm.get("title") or "(untitled)",
                "due": None,
                "state": cwm.get("state"),
                "description": cwm.get("description"),
                "links": links,
                "unsupported": unsupported,
            })

        readme_announcements = []
        for ann in course.get("announcements", []):
            label = (ann.get("text") or "")[:50] or "(no text)"
            item_dir = os.path.join(announcements_dir, slugify(label)[:60] + "-" + (ann.get("id") or "")[-6:])
            context = f"{semester}/{code} announcement ({ann.get('id')})"
            unsupported, links = process_item(drive, ann, "materials", drive_files, item_dir, failures, context, counts)
            unsupported_total += len(unsupported)
            readme_announcements.append({
                "title": label,
                "due": None,
                "state": ann.get("state"),
                "description": ann.get("text"),
                "links": links,
                "unsupported": unsupported,
            })

        readme = build_readme(
            mapping["name"], course_id, mapping.get("section"),
            [
                ("Assignments", readme_assignments),
                ("Materials", readme_materials),
                ("Announcements", readme_announcements),
            ],
        )
        with open(os.path.join(base, "README.md"), "w", encoding="utf-8") as f:
            f.write(readme)

    with open(FAILURES_LOG_PATH, "w", encoding="utf-8") as f:
        for fail in failures:
            f.write(json.dumps(fail) + "\n")

    print("\n" + "=" * 60)
    print("PHASE 4 DOWNLOAD SUMMARY")
    print("=" * 60)
    print(f"Downloaded: {counts['downloaded']}")
    print(f"Skipped (already present): {counts['skipped']}")
    print(f"Failed: {counts['failed']}")
    print(f"Unsupported (no export target / unresolved, linked in README instead): {unsupported_total}")
    if failures:
        print(f"\nFailures logged to {FAILURES_LOG_PATH}")


if __name__ == "__main__":
    main()
