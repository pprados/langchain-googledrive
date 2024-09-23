import io
import json
import os
from pathlib import Path

from langchain_googledrive.tools.google_drive.tool import GoogleDriveSearchTool
from langchain_googledrive.utilities.google_drive import GoogleDriveAPIWrapper


def test_google_drive() -> None:
    folder_id = "root"

    # By default, search only in the filename.
    tool = GoogleDriveSearchTool(
        api_wrapper=GoogleDriveAPIWrapper(
            folder_id=folder_id,
            num_results=2,
            template="gdrive-query-in-folder",  # Search in the body of documents
        )
    )
    import logging

    logging.basicConfig(level=logging.INFO)
    print(tool.run("machine learning"))
    print(tool.description)

    # %%
    from langchain.agents import AgentType, initialize_agent
    from langchain_openai import OpenAI

    llm = OpenAI(model="gpt-4o-mini", temperature=0)
    agent = initialize_agent(
        tools=[tool],
        llm=llm,
        agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
    )
    print(agent.run("Search in google drive, who is 'Yann LeCun' ?"))


def test_google_drive_with_credential() -> None:
    folder_id = "root"
    try:
        from google.oauth2.credentials import Credentials  # type: ignore
    except ImportError:
        raise ImportError(
            "You must run "
            "`pip install --upgrade "
            "google-api-python-client google-auth-httplib2 "
            "google-auth-oauthlib` "
            "to use the Google Drive loader."
        )

    gdrive_api_file = Path(os.environ["GOOGLE_ACCOUNT_FILE"])
    token_path = gdrive_api_file.parent / "token.json"
    if not token_path:
        token_path = Path("./token.json")
    if token_path and token_path.exists():
        with io.open(token_path, "r", encoding="utf-8-sig") as json_file:
            token = json.load(json_file)
    else:
        token = json.loads(os.environ["GOOGLE_ACCOUNT_TOKEN"])

    scopes = ["https://www.googleapis.com/auth/drive.readonly"]
    credentials = (
        Credentials.from_authorized_user_info(token, scopes) if token else None
    )

    # By default, search only in the filename.
    tool = GoogleDriveSearchTool(
        api_wrapper=GoogleDriveAPIWrapper(
            credentials=credentials,
            folder_id=folder_id,
            num_results=2,
            template="gdrive-query-in-folder",  # Search in the body of documents
        )
    )
    import logging

    logging.basicConfig(level=logging.INFO)
    print(tool.run("machine learning"))
    print(tool.description)

    # %%
    from langchain.agents import AgentType, initialize_agent
    from langchain_openai import OpenAI

    llm = OpenAI(model="gpt-4o-mini", temperature=0)
    agent = initialize_agent(
        tools=[tool],
        llm=llm,
        agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
    )
    print(agent.run("Search in google drive, who is 'Yann LeCun' ?"))
