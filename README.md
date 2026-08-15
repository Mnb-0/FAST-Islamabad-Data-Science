# FAST Islamabad -- Data Science coursework archive

Personal archive of my Google Classroom coursework at FAST-NUCES (BS Data Science). Built with a small Python tool (`classroom_tool/`) against the Classroom and Drive APIs.

**What's in this repo**: my own submitted work for each assignment (`.../assignments/<assignment>/my-submission/`), the generated per-course `README.md` files (assignment titles, due dates, descriptions), and the tooling itself (`classroom_tool/`, `phase1_auth_spike/`).

**What's deliberately NOT in this repo**: teacher-posted materials, lecture slides/videos/PDFs, and announcement text. Those stay on my local disk only -- they're not mine to redistribute publicly (copyright), and some contain other people's personal information (e.g. an instructor's office contact details appear in one course's metadata).

## Layout

```
<semester>/<course-code>/
  README.md                          -- assignment titles, due dates, descriptions
  assignments/<assignment>/
    my-submission/                   -- what I actually turned in
classroom_tool/
  auth.py, inventory.py, map_semesters.py, download.py, fetch_submissions.py
  courses.yaml                       -- semester/course-code mapping (hand-edited)
  inventory.json                     -- full metadata inventory (attachments, sizes, mimeTypes)
```

## Commit history

Organized as one commit per semester (tooling/metadata first, then Fall2023 through Summer2026), for readability.
