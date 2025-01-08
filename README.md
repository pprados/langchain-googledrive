This is a more advanced integration of Google Drive with langchain.

# Install
```
pip install langchain-googledrive
```

# For debug
```
poetry install --with test
make test
```

## Documentation

Documentation is available in the [docs](docs) folder in the form of Jupyter notebooks.

- [Document Loaders](docs/integrations/document_loaders/google_drive.ipynb)
- [Retrievers](docs/integrations/retrievers/google_drive.ipynb)
- [Toolkits](docs/integrations/toolkits/google_drive.ipynb)
- [Tools](docs/integrations/tools/google_drive.ipynb)

## Dependencies

In order to support advanced features, you may need to install the following optional dependencies:

| Dependency | Purpose |
|------------|---------|
| `unstructured` | Parsing and extracting text from various unstructured document formats |
| `pdf2image` | Converting PDF files to images for OCR processing |
| `pypandoc` | Converting between different document formats |
| `pytesseract` | Performing OCR (Optical Character Recognition) on images and scanned documents |
| `pdfminer.six` | Extracting text and metadata from PDF documents |
| `pi_heif` | Handling HEIF (High Efficiency Image Format) image files |
| `detectron2` | Advanced image analysis for complex document structures |

These dependencies enhance the ability to process and extract information from a wide variety of file types that may be stored in Google Drive. Install the ones you need based on the types of documents you expect to work with.
