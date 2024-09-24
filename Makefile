SHELL=/bin/bash
.PHONY: all format lint test tests test_watch integration_tests docker_tests help extended_tests
POETRY_EXTRA?=
#POETRY_EXTRA?=--all-extras
POETRY_WITH?=dev,lint,test,codespell

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

integration_tests:
	poetry run pytest tests/integration_tests

######################
# LINTING AND FORMATTING
######################

# Define a variable for Python and notebook files.
PYTHON_FILES=.
lint format: PYTHON_FILES=.
lint_diff format_diff: PYTHON_FILES=$(shell git diff --relative=libs/experimental --name-only --diff-filter=d master | grep -E '\.py$$|\.ipynb$$')

lint lint_diff:
	poetry run mypy --install-types --non-interactive $(PYTHON_FILES)
	poetry run black $(PYTHON_FILES) --check
	poetry run ruff check --select I $(PYTHON_FILES)

format format_diff:
	poetry run black $(PYTHON_FILES)
	poetry run ruff check --select I --fix $(PYTHON_FILES)

spell_check:
	poetry run codespell --toml pyproject.toml

spell_fix:
	poetry run codespell --toml pyproject.toml -w

## Validate the code (invoked before commit)
validate: format lint spell_check test

######################
# DOCUMENTATION
######################

clean: docs_clean api_docs_clean
	rm -Rf dist/*


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

poetry.lock: pyproject.toml
	@poetry lock
	@touch poetry.lock
	@git add poetry.lock
	@poetry install --sync --with dev,lint,test,codespell

## Refresh lock
lock: poetry.lock
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
	twine upload --repository-url https://test.pypi.org/legacy/ \
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
	twine upload \
		$(shell find dist -type f \( -name "*.whl" -or -name '*.gz' \) -and ! -iname "*dev*" )

endif

LANGCHAIN_HOME=../langchain
TARGET:=langchain
SRC_PACKAGE=langchain_googledrive
DST_PACKAGE=langchain
SRC_MODULE:=langchain-googledrive
DST_MODULE:=langchain

define _push_sync
	@$(eval TARGET=$(TARGET))
	@$(eval SRC_PACKAGE=$(SRC_PACKAGE))
	@$(eval DST_PACKAGE=$(DST_PACKAGE))
	@$(eval WORK_DIR=$(shell mktemp -d --suffix ".rsync"))
	@mkdir -p "${WORK_DIR}/libs/${TARGET}"
	@mkdir -p "${WORK_DIR}/docs/docs"
	@echo Copy and patch $(SRC_PACKAGE) to $(DST_PACKAGE) in $(LANGCHAIN_HOME)
	@( \
		cd $(SRC_PACKAGE)/ ; \
		rsync -a \
		  --exclude ".*" \
		  --exclude __pycache__ \
		  --exclude __init__.py \
		  . "${WORK_DIR}/libs/${TARGET}/$(DST_PACKAGE)" ; \
	)
	@( \
		cd tests/ ; \
		rsync -a \
		  --exclude ".*" \
		  --exclude __pycache__ \
		  --exclude __init__.py \
		  . "${WORK_DIR}/libs/${TARGET}/tests" ; \
	)
	@( \
		cd docs/ ; \
		rsync -a \
		  --exclude ".*" \
		  . "${WORK_DIR}/docs/docs" ; \
	)
	@find '${WORK_DIR}' -type f -a \
		-exec sed -i "s/${SRC_PACKAGE}/${DST_PACKAGE}/g" {} ';' \
		-exec sed -i "s/pip install -q '$(SRC_MODULE)'/pip install -q '$(DST_MODULE)'/g" {} ';'
	@cp -R "${WORK_DIR}/libs" "${WORK_DIR}/docs" $(LANGCHAIN_HOME)/
	@rm -Rf '${WORK_DIR}'
endef

push-sync:
	$(call _push_sync)

init: poetry.lock
	@poetry self add poetry-dotenv-plugin
	@poetry self add poetry-plugin-export
	@poetry self add poetry-git-version-plugin
	@poetry config warnings.export false
	@poetry config virtualenvs.in-project true
	@poetry install --sync $(POETRY_EXTRA) --with $(POETRY_WITH)
#	@pre-commit install
	@git lfs install
	@git lfs track "*.pdf"
