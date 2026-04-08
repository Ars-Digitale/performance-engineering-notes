#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LANG="${1:-en}"

SRC_DIR="$ROOT_DIR/docs"
TMP_DIR="$ROOT_DIR/build/pandoc"
DIST_DIR="$ROOT_DIR/dist"
ASSETS_DIR="$ROOT_DIR/assets"

BOOK_LIST="$ROOT_DIR/scripts/book-files-en.txt"
PY_SCRIPT="$ROOT_DIR/scripts/preprocess_admonitions.py"

OUTPUT_BASENAME="performance-engineering-guide-en"
EPUB_PATH="$DIST_DIR/$OUTPUT_BASENAME.epub"

TITLE="Performance Engineering Notes"
AUTHOR="Ars Digitale"

mkdir -p "$DIST_DIR"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "Preprocessing Markdown..."
python "$PY_SCRIPT" "$SRC_DIR" "$TMP_DIR"

echo "Preparing book file list..."

mapfile -t BOOK_FILES < <(
  sed 's/\r$//' "$BOOK_LIST" \
    | sed '/^[[:space:]]*$/d' \
    | sed '/^[[:space:]]*#/d' \
    | sed "s|^docs/|$TMP_DIR/|"
)

echo "Building EPUB..."

pandoc \
  --standalone \
  --from=markdown+header_attributes+fenced_divs+raw_html+smart \
  --to=epub3 \
  --css="$ASSETS_DIR/epub.css" \
  --metadata title="$TITLE" \
  --metadata author="$AUTHOR" \
  "${BOOK_FILES[@]}" \
  -o "$EPUB_PATH"

echo "EPUB created at: $EPUB_PATH"