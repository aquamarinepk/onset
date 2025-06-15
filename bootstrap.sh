#!/bin/bash

# To scaffold a new project based on this template:
# curl -s https://raw.githubusercontent.com/aquamarinepk/onset/main/bootstrap.sh | bash -s github.com/yourname/yourproject

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <new-module-path>"
  exit 1
fi

NEW_MODULE="$1"
TEMPLATE_REPO="https://github.com/aquamarinepk/onset.git"
ORIGINAL_DIR="$(pwd)"

WORKDIR=$(mktemp -d)
echo "Cloning template from $TEMPLATE_REPO into $WORKDIR..."
git clone --depth 1 "$TEMPLATE_REPO" "$WORKDIR"
cd "$WORKDIR"

ORIGINAL_MODULE=$(grep "^module " go.mod | awk '{print $2}')
echo "Updating Go module path from $ORIGINAL_MODULE to $NEW_MODULE"

go mod edit -module "$NEW_MODULE"
find . -type f -name "*.go" -exec sed -i "s|$ORIGINAL_MODULE|$NEW_MODULE|g" {} +

PROJECT_NAME_RAW=$(basename "$NEW_MODULE")

LOWERCASE_APP_NAME=$(echo "$PROJECT_NAME_RAW" | tr '[:upper:]' '[:lower:]')
echo "Updating APP_NAME from onset to $LOWERCASE_APP_NAME in Makefile(s)"

find . -maxdepth 1 \( -name "Makefile" -o -name "makefile" \) -exec sed -i "s|APP_NAME = onset|APP_NAME = $LOWERCASE_APP_NAME|g" {} +

PROJECT_NAME_SANITIZED=$(echo "$PROJECT_NAME_RAW" | sed 's/-/_/g')
NEW_ENV_PREFIX_BASE=$(echo "$PROJECT_NAME_SANITIZED" | tr '[:lower:]' '[:upper:]')
ACTUAL_NEW_PREFIX="${NEW_ENV_PREFIX_BASE}_"

echo "Updating environment variable prefix from ONSET_ to $ACTUAL_NEW_PREFIX in relevant project files (including Makefile/makefile)"

find . -path "./.git" -prune -o -type f \
  \( -name "*.go" -o \
     -name "*.sh" -o \
     -name "Makefile" -o -name "makefile" -o \
     -iname "*.md" -o \
     -name "*.yml" -o \
     -name "*.yaml" \) \
  -exec sed -i "s|ONSET_|$ACTUAL_NEW_PREFIX|g" {} +

echo "Removing .git directory from cloned template..."
rm -rf .git

TARGET_DIR="$ORIGINAL_DIR/$PROJECT_NAME_RAW" 
echo "Copying customized project to $TARGET_DIR..."

cp -R . "$TARGET_DIR"

echo "Bootstrap complete. New project created at $TARGET_DIR"

echo "Cleaning up temporary directory $WORKDIR..."
cd "$ORIGINAL_DIR" 

rm -rf "$WORKDIR"

echo "Done."

