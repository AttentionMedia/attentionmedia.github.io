#!/bin/bash
# Encrypts all HTML files from source/ into public-encrypted/ using staticrypt.
# Reads the master secret from .env — never commit .env.

REPO_ROOT="$(git rev-parse --show-toplevel)"
ENV_FILE="$REPO_ROOT/.env"
SOURCE_DIR="$REPO_ROOT/source"
OUTPUT_DIR="$REPO_ROOT/public-encrypted"

if [ ! -f "$ENV_FILE" ]; then
  echo "encrypt.sh: .env not found — skipping encryption"
  exit 0
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

if [ -z "$ENCRYPTION_SECRET" ]; then
  echo "encrypt.sh: ENCRYPTION_SECRET not set in .env — skipping"
  exit 0
fi

HTML_FILES=$(find "$SOURCE_DIR" -name "*.html" 2>/dev/null)

if [ -z "$HTML_FILES" ]; then
  exit 0
fi

for FILE in $HTML_FILES; do
  FILENAME=$(basename "$FILE")
  "$REPO_ROOT/node_modules/.bin/staticrypt" "$FILE" \
    --password "$ENCRYPTION_SECRET" \
    --output "$OUTPUT_DIR/$FILENAME" \
    --short 2>/dev/null
  echo "encrypt.sh: encrypted $FILENAME"
  git add "$OUTPUT_DIR/$FILENAME"
done
