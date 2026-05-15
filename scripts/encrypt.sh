#!/bin/bash
# Encrypts all HTML files from source/ into public-encrypted/ using staticrypt.
# Reads the master secret from .env — never commit .env.

REPO_ROOT="$(git rev-parse --show-toplevel)"
ENV_FILE="$REPO_ROOT/.env"
SOURCE_DIR="$REPO_ROOT/source"
OUTPUT_DIR="$REPO_ROOT/public-encrypted"
STATICRYPT="$REPO_ROOT/node_modules/.bin/staticrypt"

if [ ! -f "$ENV_FILE" ]; then
  echo "encrypt.sh: .env not found — skipping encryption"
  exit 0
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "$ENCRYPTION_SECRET" ]; then
  echo "encrypt.sh: ENCRYPTION_SECRET not set in .env — skipping"
  exit 0
fi

FOUND=0

while IFS= read -r -d '' FILE; do
  FOUND=1
  FILENAME=$(basename "$FILE")
  "$STATICRYPT" "$FILE" \
    --password "$ENCRYPTION_SECRET" \
    --directory "$OUTPUT_DIR" \
    --template "$REPO_ROOT/scripts/access-template.html" \
    --short \
    --config false 2>/dev/null
  echo "encrypt.sh: encrypted $FILENAME → public-encrypted/$FILENAME"
done < <(find "$SOURCE_DIR" -name "*.html" -print0 2>/dev/null)

if [ "$FOUND" -eq 1 ]; then
  git -C "$REPO_ROOT" add "$OUTPUT_DIR/"
fi

if [ "$FOUND" -eq 0 ]; then
  echo "encrypt.sh: no HTML files found in source/ — skipping"
fi
