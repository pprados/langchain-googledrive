This is a more advanced integration of Google Drive with langchain.

# Install
```
pip install langchain-googledrive
```

# For debug
```
poetry install -with test
make test
```

# Features:

Langchain component:
- [Document Loaders](docs/integrations/document_loaders/google_drive.ipynb)
- [Retrievers](docs/integrations/retrievers/google_drive.ipynb)
- [Toolkits](docs/integrations/toolkits/google_drive.ipynb)

Fully compatible with Google Drive API
- Manage file in trash
- Manage shortcut
- Manage file description
- Paging with request GDrive list()
- Multiple kinds of template for request GDrive
- Convert a lot of mime type (can be configured). The list is adjusted according to the packages availables
- Can use only the description of files, without loading and conversion of the body
- Lambda fine filter
- Remove duplicate documents (in case of shortcut)
- Add Url to documents (or part of documents like specific slide)
- Use environment variable for reference an API tokens
- Manage different king of strange state with Google File (absence of URL, etc.)
- Use fully lazy strategy to save memory
- Convert GDoc, GSheet and GSlide with different modes
    - Extract text, bullet point, tables, titles, links

  
# langchain Pull-request
I couldn't get a [pull-request](https://github.com/hwchase17/langchain/pull/5135) accepted because 
the project is too big.
Sorry for that.
