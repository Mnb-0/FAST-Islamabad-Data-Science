"""
Phase 3 -- propose a semester + course-code mapping from inventory.json,
write it to courses.yaml for hand-editing. No Google API calls here (the
Classroom API has no semester field, per the task spec), so nothing to
verify against docs -- this is pure local heuristics over data already
fetched in Phase 2.

Heuristic (deliberately NOT trusting year/semester tokens embedded in
course names -- see note below):
  - semester is derived purely from creationTime month/year:
      Aug-Dec  -> Fall<year>
      Jan-May  -> Spring<year>
      Jun-Jul  -> Summer<year>  (rare; flagged low-confidence)
  - course_code is derived by looking for a Dept+Number pattern in the
    course name (e.g. "CS2005", "MT-1004", "SS 2012"); falls back to a
    slugified short form of the name if no such pattern is found.

Why not trust name-embedded years (e.g. "F-25", "SP26", "Batch-2023"):
cross-checking against creationTime showed these frequently refer to
student cohort/batch year, not the semester the course was actually
delivered in -- e.g. "Probability & Statistics F-25" has creationTime in
Aug 2024, and "BS(DS-B)_SS 2012_Technical and Business Writing" has "SS
2012" as its course code, not a year. creationTime is the reliable
signal; this script surfaces the name as context but doesn't parse
semester out of it.
"""

import json
import os
import re

import yaml

TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
INVENTORY_PATH = os.path.join(TOOL_DIR, "inventory.json")
COURSES_YAML_PATH = os.path.join(TOOL_DIR, "courses.yaml")

# Dept-code + catalog-number pattern, e.g. CS2005, MT-1004, SS 2012.
# Letters must be uppercase in the source text to avoid matching regular
# words; number must be 3-4 digits to avoid matching things like "SP26".
# Uses lookaround instead of \b: names like "BS(DS-B)_SS 2012_..." have
# underscores directly against the code, and \b treats underscore as a
# word character (so it fails to find a boundary there).
CODE_PATTERN = re.compile(r"(?<![A-Za-z0-9])([A-Z]{2,4})[\s-]?(\d{3,4})(?![A-Za-z0-9])")

SEMESTER_WORD_DENYLIST = {"FALL", "TERM", "YEAR", "SEM"}


def derive_semester(creation_time):
    # creationTime format confirmed at:
    # https://developers.google.com/classroom/reference/rest/v1/courses
    # RFC 3339, e.g. "2025-08-12T08:55:41.259Z"
    year = int(creation_time[0:4])
    month = int(creation_time[5:7])

    if 8 <= month <= 12:
        return f"Fall{year}", "high"
    if 1 <= month <= 5:
        return f"Spring{year}", "high"
    return f"Summer{year}", "low"  # Jun-Jul: uncommon, flagged for review


def derive_course_code(name):
    for match in CODE_PATTERN.finditer(name):
        letters = match.group(1)
        # Reject semester/term words that happen to satisfy the 2-4
        # uppercase-letter shape (e.g. "FALL 2025" -> "FALL"+"2025").
        # Found via "Operating Systems FALL 2025" matching as FALL2025.
        if letters in SEMESTER_WORD_DENYLIST:
            continue
        return f"{letters}{match.group(2)}", "high"

    slug = name.lower()
    slug = re.sub(r"[^a-z0-9]+", "-", slug).strip("-")
    slug = re.sub(r"-{2,}", "-", slug)
    words = slug.split("-")
    slug = "-".join(words[:5])[:40].strip("-")
    return slug or "course", "low"


def main():
    with open(INVENTORY_PATH, "r", encoding="utf-8") as f:
        inventory = json.load(f)

    courses = inventory["courses"]
    courses_sorted = sorted(courses, key=lambda c: c.get("creationTime") or "")

    seen_codes = {}  # (semester, code) -> count, for collision suffixing
    entries = {}

    for course in courses_sorted:
        course_id = course["id"]
        name = course.get("name") or ""
        section = course.get("section")
        creation_time = course.get("creationTime")

        semester, sem_confidence = derive_semester(creation_time)
        code, code_confidence = derive_course_code(name)

        key = (semester, code)
        seen_codes[key] = seen_codes.get(key, 0) + 1
        if seen_codes[key] > 1:
            code = f"{code}-{seen_codes[key]}"

        entry = {
            "name": name,
            "section": section,
            "creation_time": creation_time,
            "semester": semester,
            "course_code": code,
            "semester_confidence": sem_confidence,
            "code_confidence": code_confidence,
        }
        entries[course_id] = entry

    excluded = inventory.get("excludedCourseIds", [])

    doc = {
        "_readme": (
            "Hand-edit semester / course_code freely, then re-run "
            "downstream phases -- they load from this file, not from "
            "inventory.json, so your edits stick. semester_confidence: "
            "low means creationTime fell in Jun/Jul (calendar-ambiguous "
            "between terms). code_confidence: low means no Dept+Number "
            "pattern was found in the course name, so a slug of the "
            "title was used instead -- cosmetic only, safe to rename."
        ),
        "courses": entries,
    }

    with open(COURSES_YAML_PATH, "w", encoding="utf-8") as f:
        yaml.dump(doc, f, sort_keys=False, allow_unicode=True, width=100)

    print(f"Wrote {COURSES_YAML_PATH}\n")
    print(f"{len(entries)} courses mapped.\n")

    sem_low = [(cid, e) for cid, e in entries.items() if e["semester_confidence"] == "low"]
    code_low = [(cid, e) for cid, e in entries.items() if e["code_confidence"] == "low"]

    print(f"{len(sem_low)} entries with LOW semester confidence (Jun/Jul creation -- genuinely ambiguous, please review):\n")
    for cid, e in sem_low:
        print(f"  [{e['semester']:12s}] {e['course_code']:30s}  {e['name']}  (id {cid})")

    print(f"\n{len(code_low)} entries with no Dept+Number code in the name (slug used instead -- cosmetic, rename at leisure):\n")
    for cid, e in code_low:
        print(f"  [{e['semester']:12s}] {e['course_code']:30s}  {e['name']}  (id {cid})")


if __name__ == "__main__":
    main()
