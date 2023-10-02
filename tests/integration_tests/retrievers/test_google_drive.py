from langchain_googledrive.retrievers import GoogleDriveRetriever


def test_google_driver() -> None:
    folder_id = "root"
    # folder_id='1yucgL9WGgWZdM1TOuKkeghlPizuzMYb6'
    retriever = GoogleDriveRetriever(
        folder_id=folder_id,
        recursive=False,
        num_results=2,  # Maximum number of file to load
    )
    for doc in retriever.get_relevant_documents(query="machine learning"):
        print("---")
        print(doc.page_content.strip()[:60] + "...")
