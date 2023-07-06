#!/usr/bin/env bash
SRC=../langchain/langchain
DST=./exlangchain
cp $SRC/docstore/google_drive.py         $DST/docstore/google_drive.py
cp $SRC/document_loaders/google_drive.py $DST/document_loaders/google_drive.py
cp $SRC/retrievers/google_drive.py       $DST/retrievers/google_drive.py
cp $SRC/tools/google_drive/tool.py       $DST/tools/google_drive/tool.py
cp $SRC/utilities/google_drive.py        $DST/utilities/google_drive.py

