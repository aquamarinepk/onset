#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <new-module-path>"
  exit 1
fi

NEW_MODULE="$1"
TEMPLATE_REPO="git@github.com:aquamarinepk/onset.git"

WORKDIR=$(mktemp -d)
echo "Cloning template..."
git clone "$TEMPLATE_REPO" "$WORKDIR"
cd "$WORKDIR"

ORIGINAL_MODULE=$(grep "^module " go.mod | awk '{print $2}')
echo "Updating module from $ORIGINAL_MODULE to $NEW_MODULE"

go mod edit -module "$NEW_MODULE"
find . -type f -name "*.go" -exec sed -i "s|$ORIGINAL_MODULE|$NEW_MODULE|g" {} +
rm -rf .git

TARGET_DIR="../$(basename "$NEW_MODULE")"
cp -R . "$TARGET_DIR"

echo "Done. Project created at $TARGET_DIR"

