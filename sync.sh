#!/usr/bin/env bash
WORKSPACE=$HOME/workspace.bda
SRC=$WORKSPACE/langchain/libs/langchain/langchain
DST=$WORKSPACE/langchain-googledrive/langchain_googledrive
SRC_TEST=$WORKSPACE/langchain/libs/langchain/tests/unit_tests
DST_TEST=$WORKSPACE/langchain-googledrive/tests/unit_tests
SRC_DOC=$WORKSPACE/langchain/docs/extras/integrations
DST_DOC=$WORKSPACE/langchain-googledrive/docs/extras/integrations
cp $SRC/document_loaders/google_drive.py $DST/document_loaders/google_drive.py
cp $SRC/retrievers/google_drive.py       $DST/retrievers/google_drive.py
cp $SRC/tools/google_drive/tool.py       $DST/tools/google_drive/tool.py
cp $SRC/utilities/google_drive.py        $DST/utilities/google_drive.py

cp $SRC_TEST/document_loaders/test_google_drive.py $DST_TEST/document_loaders/
cp $SRC_TEST/retrievers/test_google_drive.py $DST_TEST/retrievers/
cp $SRC_TEST/utilities/test_google_drive.py $DST_TEST/utilities/
cp -r $SRC_TEST/utilities/examples/* $DST_TEST/utilities/examples/
cp $SRC_TEST/llms/fake* $DST_TEST/llms
cp $SRC_TEST/llms/__init__* $DST_TEST/llms
cp $SRC_TEST/callbacks/fake* $DST_TEST/callbacks
cp $SRC_TEST/callbacks/__init__* $DST_TEST/callbacks

cp $SRC_DOC/document_loaders/google_drive.ipynb $DST_DOC/document_loaders/google_drive.ipynb
cp $SRC_DOC/providers/google_drive.mdx $DST_DOC/providers/google_drive.mdx
cp $SRC_DOC/retrievers/google_drive.ipynb $DST_DOC/retrievers/google_drive.ipynb
cp $SRC_DOC/toolkits/google_drive.ipynb $DST_DOC/toolkits/google_drive.ipynb

