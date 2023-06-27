from typing import Any, Dict, Union

from pydantic.class_validators import root_validator

from langchain.docstore.base import Docstore
from langchain.schema import Document

from ..utilities.google_drive import GoogleDriveUtilities, get_template


class GoogleDriveDocStore(Docstore, GoogleDriveUtilities):

    """
    Read only docstore on Google Drive.
    By default, uses the filename to search.
    You can change it with a new template.
    """

    @root_validator(pre=True)
    def validate_template(cls, v: Dict[str, Any]) -> Dict[str, Any]:
        folder_id = v.get("folder_id")

        if "template" not in v:
            if folder_id:
                template = get_template("gdrive-by-name-in-folders")
            else:
                template = get_template("gdrive-by-name")
            v["template"] = template
        return v

    def search(self, search: str) -> Union[str, Document]:
        """Try to search for document.

        If document exists, return the document `description` and
        a PageWithLookups object.
        If page does not exist, return an error message.
        """
        try:
            result = next(self.lazy_get_relevant_documents(query=search))
            return Document(
                page_content=result.page_content + "\n",
                metadata={"page": result.metadata["source"]},
            )
        except StopIteration:
            return f"Could not find [{search}]."
