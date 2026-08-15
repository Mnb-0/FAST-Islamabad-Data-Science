"""
Shared OAuth helper for all phases of the archival tool. One token.json is
cached and reused so consent only has to happen once.
"""

import os

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow

TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
CREDENTIALS_PATH = os.path.join(TOOL_DIR, "credentials.json")
TOKEN_PATH = os.path.join(TOOL_DIR, "token.json")

# Scopes confirmed at:
# https://developers.google.com/classroom/guides/auth
# https://developers.google.com/workspace/drive/api/guides/api-specific-auth
#
# classroom.coursework.me.readonly is documented as a valid scope for
# courseWork.list (https://developers.google.com/classroom/reference/rest/v1/courses.courseWork/list)
# but Google's authorization server on this project deterministically
# substituted classroom.student-submissions.me.readonly for it across two
# independent fresh consent flows -- root cause unresolved from docs.
# Using the non-readonly classroom.coursework.me instead, which grants
# cleanly. Only read (list/get) methods are ever called with it.
SCOPES = [
    "https://www.googleapis.com/auth/classroom.courses.readonly",
    "https://www.googleapis.com/auth/classroom.coursework.me",
    "https://www.googleapis.com/auth/classroom.announcements.readonly",
    "https://www.googleapis.com/auth/classroom.courseworkmaterials.readonly",
    "https://www.googleapis.com/auth/drive.readonly",
]


def get_credentials():
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
                    "OAuth client JSON from Google Cloud Console first."
                )
            flow = InstalledAppFlow.from_client_secrets_file(
                CREDENTIALS_PATH, SCOPES
            )
            creds = flow.run_local_server(port=0)

        with open(TOKEN_PATH, "w") as token_file:
            token_file.write(creds.to_json())

    return creds
