#!/usr/bin/env bash

EXCLUDE_PATTERNS=''
while IFS= read -r PATTERN
do
  EXCLUDE_PATTERNS="$EXCLUDE_PATTERNS --exclude=*$PATTERN*"
done < "./.packageignore"

zip -r $EXCLUDE_PATTERNS dist/handler.zip ./

cd vendor || exit 1

zip -r dist/lib-layer.zip ./lib
