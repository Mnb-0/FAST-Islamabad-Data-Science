"""
Phase 1 auth spike: OAuth against a desktop client, then call Classroom
courses.list. This is the "kill switch" test -- if FAST-NUCES has blocked
third-party OAuth apps at the Workspace admin level, or requires
verification we don't have, this will fail with a diagnosable error here
before any other code gets written.

Requires credentials.json (Desktop app OAuth client, downloaded from
Google Cloud Console) in this same directory. See the manual console
steps given alongside this script.
"""

import os

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CREDENTIALS_PATH = os.path.join(SCRIPT_DIR, "credentials.json")
TOKEN_PATH = os.path.join(SCRIPT_DIR, "token.json")

# Scopes confirmed at:
# https://developers.google.com/classroom/guides/auth
# https://developers.google.com/workspace/drive/api/guides/api-specific-auth
#
# NOTE: classroom.coursework.me.readonly is documented as valid
# (https://developers.google.com/classroom/reference/rest/v1/courses.courseWork/list)
# but Google's authorization server was observed silently substituting
# classroom.student-submissions.me.readonly for it on this project, across
# two independent fresh consent flows -- root cause unresolved. Using the
# non-readonly classroom.coursework.me instead, which granted cleanly. We
# will only ever call read (list/get) methods with it.
SCOPES = [
    "https://www.googleapis.com/auth/classroom.courses.readonly",
    "https://www.googleapis.com/auth/classroom.coursework.me",
    "https://www.googleapis.com/auth/classroom.announcements.readonly",
    "https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly",
    "https://www.googleapis.com/auth/drive.readonly",
]


def get_credentials():
    # Token cache / refresh / InstalledAppFlow pattern confirmed at:
    # https://developers.google.com/workspace/classroom/quickstart/python
    creds = None
    if os.path.exists(TOKEN_PATH):
        creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(CREDENTIALS_PATH):
                raise SystemExit(
                    f"Missing {CREDENTIALS_PATH}. Download the Desktop app "
                    "OAuth client JSON from Google Cloud Console and save "
                    "it there first."
                )
            # Desktop app flow (loopback redirect, NOT the deprecated OOB
            # flow) confirmed at:
            # https://developers.google.com/identity/protocols/oauth2/native-app
            flow = InstalledAppFlow.from_client_secrets_file(
                CREDENTIALS_PATH, SCOPES
            )
            creds = flow.run_local_server(port=0)

        with open(TOKEN_PATH, "w") as token_file:
            token_file.write(creds.to_json())

    return creds


def main():
    creds = get_credentials()
    service = build("classroom", "v1", credentials=creds)

    print("Courses:\n")
    page_token = None
    total = 0
    try:
        while True:
            # courses.list confirmed at:
            # https://developers.google.com/classroom/reference/rest/v1/courses/list
            response = (
                service.courses()
                .list(pageSize=100, pageToken=page_token)
                .execute()
            )
            for course in response.get("courses", []):
                total += 1
                print(f"id:           {course.get('id')}")
                print(f"name:         {course.get('name')}")
                print(f"section:      {course.get('section')}")
                print(f"creationTime: {course.get('creationTime')}")
                print("-" * 40)

            page_token = response.get("nextPageToken")
            if not page_token:
                break
    except HttpError as err:
        print("\nAPI call failed. Raw error for diagnosis:\n")
        print(err)
        raise

    print(f"\nTotal courses returned: {total}")


if __name__ == "__main__":
    main()
