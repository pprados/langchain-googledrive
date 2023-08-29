SHELL=/bin/bash
.PHONY: all format lint test tests test_watch integration_tests docker_tests help extended_tests

# Default target executed when no arguments are given to make.
all: help

# Define a variable for the test file path.
TEST_FILE ?= tests/unit_tests/

test:
	poetry run pytest -v $(TEST_FILE)

tests: 
	poetry run pytest -v $(TEST_FILE)

test_watch:
	poetry run ptw --now . -- tests/unit_tests


######################
# LINTING AND FORMATTING
######################

# Define a variable for Python and notebook files.
PYTHON_FILES=.
lint format: PYTHON_FILES=.
lint_diff format_diff: PYTHON_FILES=$(shell git diff --relative=libs/experimental --name-only --diff-filter=d master | grep -E '\.py$$|\.ipynb$$')

lint lint_diff:
	poetry run mypy $(PYTHON_FILES)
	poetry run black $(PYTHON_FILES) --check
	poetry run ruff .

format format_diff:
	poetry run black $(PYTHON_FILES)
	poetry run ruff --select I --fix $(PYTHON_FILES)

spell_check:
	poetry run codespell --toml pyproject.toml

spell_fix:
	poetry run codespell --toml pyproject.toml -w


######################
# DOCUMENTATION
######################

clean: docs_clean api_docs_clean


docs_build:
	docs/.local_build.sh

docs_clean:
	rm -rf docs/_dist

docs_linkcheck:
	poetry run linkchecker docs/_dist/docs_skeleton/ --ignore-url node_modules

api_docs_build:
#	poetry run python docs/api_reference/create_api_rst.py
#	cd docs/api_reference && poetry run make html

api_docs_clean:
#	rm -f docs/api_reference/api_reference.rst
#	cd docs/api_reference && poetry run make clean


api_docs_linkcheck:
	poetry run linkchecker docs/api_reference/_build/html/index.html

######################
# HELP
######################

help:
	@echo '----'
	@echo 'format                       - run code formatters'
	@echo 'lint                         - run linters'
	@echo 'test                         - run unit tests'
	@echo 'tests                        - run unit tests'
	@echo 'test TEST_FILE=<test_file>   - run all tests in file'
	@echo 'test_watch                   - run unit tests in watch mode'
	@echo 'clean                        - run docs_clean and api_docs_clean'
	@echo 'docs_build                   - build the documentation'
	@echo 'docs_clean                   - clean the documentation build artifacts'
	@echo 'docs_linkcheck               - run linkchecker on the documentation'
	@echo 'api_docs_build               - build the API Reference documentation'
	@echo 'api_docs_clean               - clean the API Reference documentation build artifacts'
	@echo 'api_docs_linkcheck           - run linkchecker on the API Reference documentation'
	@echo 'spell_check               	- run codespell on the project'
	@echo 'spell_fix               		- run codespell on the project and fix the errors'


.PHONY: dist
dist:
	poetry build

# ---------------------------------------------------------------------------------------
# SNIPPET pour tester la publication d'une distribution
# sur test.pypi.org.
.PHONY: test-twine
## Publish distribution on test.pypi.org
test-twine: dist
ifeq ($(OFFLINE),True)
	@echo -e "$(red)Can not test-twine in offline mode$(normal)"
else
	@$(VALIDATE_VENV)
	rm -f dist/*.asc
	twine upload --sign --repository-url https://test.pypi.org/legacy/ \
		$(shell find dist -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )
endif

# ---------------------------------------------------------------------------------------
# SNIPPET pour publier la version sur pypi.org.
.PHONY: release
## Publish distribution on pypi.org
release: clean dist
ifeq ($(OFFLINE),True)
	@echo -e "$(red)Can not release in offline mode$(normal)"
else
	@$(VALIDATE_VENV)
	[[ $$( find dist -name "*.dev*" | wc -l ) == 0 ]] || \
		( echo -e "$(red)Add a tag version in GIT before release$(normal)" \
		; exit 1 )
	rm -f dist/*.asc
	echo "Enter Pypi password"
	twine upload --sign \
		$(shell find dist -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )

endif


SRC=../langchain/libs/langchain/langchain
DST=langchain_googledrive
SRC_TEST=../langchain/libs/langchain/tests/unit_tests
DST_TEST=tests/unit_tests
SRC_DOC=../langchain/docs/extras/integrations
DST_DOC=docs/extras/integrations

.PHONY: sync
sync:
	cp $(SRC)/document_loaders/google_drive.py $(DST)/document_loaders/google_drive.py
	cp $(SRC)/retrievers/google_drive.py       $(DST)/retrievers/google_drive.py
	cp $(SRC)/tools/google_drive/tool.py       $(DST)/tools/google_drive/tool.py
	cp $(SRC)/utilities/google_drive.py        $(DST)/utilities/google_drive.py

	cp $(SRC_TEST)/document_loaders/test_google_drive.py 	$(DST_TEST)/document_loaders/
	cp $(SRC_TEST)/retrievers/test_google_drive.py 			$(DST_TEST)/retrievers/
	cp $(SRC_TEST)/utilities/test_google_drive.py 			$(DST_TEST)/utilities/
	cp -r $(SRC_TEST)/utilities/examples/* 					$(DST_TEST)/utilities/examples/
	cp $(SRC_TEST)/llms/fake* 								$(DST_TEST)/llms
	cp $(SRC_TEST)/llms/__init__* 							$(DST_TEST)/llms
	cp $(SRC_TEST)/callbacks/fake* 							$(DST_TEST)/callbacks
	cp $(SRC_TEST)/callbacks/__init__* 						$(DST_TEST)/callbacks

	cp $(SRC_DOC)/document_loaders/google_drive.ipynb 		$(DST_DOC)/document_loaders/google_drive.ipynb
	cp $(SRC_DOC)/providers/google_drive.mdx 				$(DST_DOC)/providers/google_drive.mdx
	cp $(SRC_DOC)/retrievers/google_drive.ipynb 			$(DST_DOC)/retrievers/google_drive.ipynb
	cp $(SRC_DOC)/toolkits/google_drive.ipynb 				$(DST_DOC)/toolkits/google_drive.ipynb

	find . -type f -name '*.py' | xargs sed -i 's/langchain.document_loaders.google_drive/langchain_googledrive.document_loaders.google_drive/g'
	find . -type f -name '*.py' | xargs sed -i 's/langchain.retrievers.google_drive/langchain_googledrive.retrievers.google_drive/g'
	find . -type f -name '*.py' | xargs sed -i 's/from langchain.utilities import GoogleDriveAPIWrapper/from langchain_googledrive.utilities import GoogleDriveAPIWrapper/g'
	find . -type f -name '*.py' | xargs sed -i 's/from langchain.utilities.google_drive/from langchain_googledrive.utilities.google_drive/g'

