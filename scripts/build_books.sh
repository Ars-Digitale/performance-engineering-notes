#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANG="${1:-en}"
FORMAT="${2:-epub}"

SRC_DIR="$ROOT_DIR/docs"
TMP_DIR="$ROOT_DIR/build/pandoc"
DIST_DIR="$ROOT_DIR/dist"
ASSETS_DIR="$ROOT_DIR/assets"
DOWNLOAD_DIR="$DIST_DIR/downloads"
PY_SCRIPT="$ROOT_DIR/scripts/preprocess_admonitions.py"
FRONTMATTER_DIR="$TMP_DIR/$LANG/frontmatter"

AUTHOR="Alessandro Fabri"
PUBLISHER="Ars Digitale"
CONTACT_EMAIL="info@ars-digitale.com"
WEBSITE="https://www.ars-digitale.com"
EDITION_LABEL="2026 Edition"
INDEX_ANCHOR="book-index"

case "$LANG" in
  en)
    TITLE="Performance Engineering Notes"
    BOOK_LIST="$ROOT_DIR/scripts/book-files-en.txt"
    OUTPUT_BASENAME="performance-engineering-guide-en"
    COVER_IMAGE="$ROOT_DIR/covers/generated/performance-en-cover-epub.png"
    DESCRIPTION_TEXT="A structured technical guide focused on application and system performance engineering."
    LANGUAGE_LABEL="Language: English"
    SUBTITLE="A structured technical reference for application and system performance engineering"
    COPYRIGHT_TITLE="Copyright"
    PREFACE_TITLE="Preface"
    ABOUT_TITLE="About This Book"
    RIGHTS_TEXT="All rights reserved."
    USAGE_LINE="This book is provided for personal study, technical reference, training, and educational use."
    CONTACT_LABEL="Contact"
    WEB_LABEL="Web"
    VERSION_LABEL="Version"
    PREFACE_BODY="This guide is designed as a structured technical reference for performance engineering, with a focus on clarity, precision, and practical usefulness.

It covers application and system behavior under load, diagnostics, bottlenecks, queueing, concurrency, runtime behavior, and resource-level performance.

Each chapter is intended to function both as part of a coherent reading path and as a standalone reference for technical analysis."
    ABOUT_BODY="This book was designed as a practical and structured reference for performance engineering.

It aims to combine:

- technical precision
- conceptual clarity
- system-level reasoning
- operational usefulness
- long-term value as a reference

The EPUB edition is optimized for digital reading and chapter-based navigation."
    ;;
  fr)
    TITLE="Notes de Performance Engineering"
    BOOK_LIST="$ROOT_DIR/scripts/book-files-fr.txt"
    OUTPUT_BASENAME="performance-engineering-guide-fr"
    COVER_IMAGE="$ROOT_DIR/covers/generated/performance-fr-cover-epub.png"
    DESCRIPTION_TEXT="Un guide technique structuré consacré à l’ingénierie de la performance applicative et système."
    LANGUAGE_LABEL="Langue : Français"
    SUBTITLE="Une référence technique structurée pour l’ingénierie de la performance applicative et système"
    COPYRIGHT_TITLE="Copyright"
    PREFACE_TITLE="Préface"
    ABOUT_TITLE="À propos de ce livre"
    RIGHTS_TEXT="Tous droits réservés."
    USAGE_LINE="Ce livre est fourni pour un usage personnel d’étude, de référence technique, de formation et d’apprentissage."
    CONTACT_LABEL="Contact"
    WEB_LABEL="Web"
    VERSION_LABEL="Version"
    PREFACE_BODY="Ce guide est conçu comme une référence technique structurée pour l’ingénierie de la performance, avec un accent particulier sur la clarté, la précision et l’utilité pratique.

Il couvre le comportement applicatif et système sous charge, le diagnostic, les goulots d’étranglement, les files d’attente, la concurrence, le comportement d’exécution et la performance au niveau des ressources.

Chaque chapitre est pensé à la fois comme une partie d’un parcours cohérent et comme une référence autonome pour l’analyse technique."
    ABOUT_BODY="Ce livre a été conçu comme une référence pratique et structurée pour l’ingénierie de la performance.

Il vise à combiner :

- précision technique
- clarté conceptuelle
- raisonnement à l’échelle du système
- utilité opérationnelle
- valeur durable comme ouvrage de référence

L’édition EPUB est optimisée pour la lecture numérique et la navigation par chapitres."
    ;;
  it)
    TITLE="Note di Performance Engineering"
    BOOK_LIST="$ROOT_DIR/scripts/book-files-it.txt"
    OUTPUT_BASENAME="performance-engineering-guide-it"
    COVER_IMAGE="$ROOT_DIR/covers/generated/performance-it-cover-epub.png"
    DESCRIPTION_TEXT="Una guida tecnica strutturata dedicata all’ingegneria delle prestazioni applicative e di sistema."
    LANGUAGE_LABEL="Lingua: Italiano"
    SUBTITLE="Un riferimento tecnico strutturato per l’ingegneria delle prestazioni applicative e di sistema"
    COPYRIGHT_TITLE="Copyright"
    PREFACE_TITLE="Prefazione"
    ABOUT_TITLE="Informazioni su questo libro"
    RIGHTS_TEXT="Tutti i diritti riservati."
    USAGE_LINE="Questo libro è fornito per studio personale, riferimento tecnico, formazione e uso educativo."
    CONTACT_LABEL="Contatto"
    WEB_LABEL="Web"
    VERSION_LABEL="Versione"
    PREFACE_BODY="Questa guida è pensata come un riferimento tecnico strutturato per l’ingegneria delle prestazioni, con particolare attenzione a chiarezza, precisione e utilità pratica.

Copre il comportamento applicativo e di sistema sotto carico, diagnostica, colli di bottiglia, accodamento, concorrenza, comportamento runtime e prestazioni a livello di risorsa.

Ogni capitolo è progettato sia come parte di un percorso coerente sia come riferimento autonomo per l’analisi tecnica."
    ABOUT_BODY="Questo libro è stato progettato come un riferimento pratico e strutturato per l’ingegneria delle prestazioni.

L’obiettivo è combinare:

- precisione tecnica
- chiarezza concettuale
- ragionamento a livello di sistema
- utilità operativa
- valore duraturo come riferimento

L’edizione EPUB è ottimizzata per la lettura digitale e la navigazione per capitoli."
    ;;
  *)
    echo "Unsupported language: $LANG"
    exit 1
    ;;
esac

case "$FORMAT" in
  epub|pdf|all) ;;
  *)
    echo "Unsupported format: $FORMAT"
    echo "Usage: bash scripts/build_books.sh [language] [epub|pdf|all]"
    exit 1
    ;;
esac

EPUB_PATH="$DIST_DIR/$OUTPUT_BASENAME.epub"
PDF_PATH="$DIST_DIR/$OUTPUT_BASENAME.pdf"
METADATA_FILE="$TMP_DIR/$LANG/metadata.yaml"

[ -f "$BOOK_LIST" ] || { echo "Missing book list: $BOOK_LIST"; exit 1; }
[ -f "$PY_SCRIPT" ] || { echo "Missing preprocessor script: $PY_SCRIPT"; exit 1; }
[ -f "$ASSETS_DIR/epub.css" ] || { echo "Missing CSS file: $ASSETS_DIR/epub.css"; exit 1; }

mkdir -p "$DIST_DIR"
mkdir -p "$DOWNLOAD_DIR"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "Preprocessing Markdown..."
python "$PY_SCRIPT" "$SRC_DIR" "$TMP_DIR"

mapfile -t BOOK_FILES < <(
  sed 's/\r$//' "$BOOK_LIST" \
    | sed '/^[[:space:]]*$/d' \
    | sed '/^[[:space:]]*#/d' \
    | sed "s|^docs/|$TMP_DIR/|"
)

[ "${#BOOK_FILES[@]}" -gt 0 ] || { echo "No chapter files found"; exit 1; }

extract_chapter_title() {
  local file="$1"
  local line
  line="$(sed -n 's/^# \(.*\)$/\1/p' "$file" | head -n 1)"
  [ -n "$line" ] || { basename "$file" .md; return; }
  line="$(printf '%s' "$line" | sed 's/[[:space:]]*{#[^}]*}[[:space:]]*$//')"
  line="$(printf '%s' "$line" | sed 's/[[:space:]]*{\.[^}]*}[[:space:]]*$//')"
  printf '%s' "$line"
}

chapter_anchor() {
  local file="$1"
  local base
  base="$(basename "$file" .md)"
  printf 'chap-%s' "$base"
}

attach_anchor_to_first_h1() {
  local file="$1"
  local anchor="$2"
  local tmp_file="${file}.tmp"

  awk -v anchor="$anchor" '
    BEGIN { done = 0 }
    /^[[:space:]]*# / && done == 0 {
      line = $0
      sub(/[[:space:]]*\{#[^}]+\}[[:space:]]*$/, "", line)
      print line " {#" anchor "}"
      done = 1
      next
    }
    { print }
  ' "$file" > "$tmp_file"

  mv "$tmp_file" "$file"
}

append_navigation_footer() {
  local file="$1"
  local prev_anchor="$2"
  local prev_title="$3"
  local next_anchor="$4"
  local next_title="$5"

  {
    echo
    echo '---'
    echo
    echo '::: {.chapter-nav}'

    if [ -n "$prev_anchor" ]; then
      printf '[◀ %s](#%s)' "$prev_title" "$prev_anchor"
    else
      printf '◀'
    fi

    printf ' | [▲ Index](#%s) | ' "$INDEX_ANCHOR"

    if [ -n "$next_anchor" ]; then
      printf '[%s ▶](#%s)\n' "$next_title" "$next_anchor"
    else
      printf '▶\n'
    fi

    echo ':::'
    echo
  } >> "$file"
}

looks_like_index_chapter() {
  local file="$1"
  case "$(basename "$file")" in
    index.md) return 0 ;;
    *) return 1 ;;
  esac
}

generate_frontmatter() {
  local dir="$1"
  mkdir -p "$dir"

  cat > "$dir/00-title.md" <<EOF_FM
<div class="book-title-page">

# $TITLE {-}

### $SUBTITLE {-}

**$AUTHOR**

</div>

$EDITION_LABEL

**$CONTACT_LABEL**: $CONTACT_EMAIL

**$WEB_LABEL**: $WEBSITE
EOF_FM

  cat > "$dir/01-copyright.md" <<EOF_FM
# $COPYRIGHT_TITLE {-}

**$TITLE**  
**$AUTHOR**

$RIGHTS_TEXT

$USAGE_LINE

$VERSION_LABEL: 1.0  
$LANGUAGE_LABEL

**$CONTACT_LABEL**: $CONTACT_EMAIL

**$WEB_LABEL**: $WEBSITE

$EDITION_LABEL
EOF_FM

  cat > "$dir/02-preface.md" <<EOF_FM
# $PREFACE_TITLE {-}

$PREFACE_BODY
EOF_FM

  cat > "$dir/03-about.md" <<EOF_FM
# $ABOUT_TITLE {-}

$ABOUT_BODY

**$CONTACT_LABEL**: $CONTACT_EMAIL

**$WEB_LABEL**: $WEBSITE
EOF_FM
}

generate_frontmatter "$FRONTMATTER_DIR"

FRONTMATTER_FILES=(
  "$FRONTMATTER_DIR/00-title.md"
  "$FRONTMATTER_DIR/01-copyright.md"
  "$FRONTMATTER_DIR/02-preface.md"
  "$FRONTMATTER_DIR/03-about.md"
)

declare -a CHAPTER_ANCHORS
declare -a CHAPTER_TITLES

BOOK_COUNT=${#BOOK_FILES[@]}

for ((i=0; i<BOOK_COUNT; i++)); do
  f="${BOOK_FILES[$i]}"
  current_title="$(extract_chapter_title "$f")"
  current_anchor="$(chapter_anchor "$f")"

  if looks_like_index_chapter "$f"; then
    current_anchor="$INDEX_ANCHOR"
  fi

  CHAPTER_ANCHORS[$i]="$current_anchor"
  CHAPTER_TITLES[$i]="$current_title"
done

for ((i=0; i<BOOK_COUNT; i++)); do
  f="${BOOK_FILES[$i]}"

  prev_anchor=""
  prev_title=""
  next_anchor=""
  next_title=""

  if [ $i -gt 0 ]; then
    prev_anchor="${CHAPTER_ANCHORS[$((i-1))]}"
    prev_title="${CHAPTER_TITLES[$((i-1))]}"
  fi

  if [ $i -lt $((BOOK_COUNT-1)) ]; then
    next_anchor="${CHAPTER_ANCHORS[$((i+1))]}"
    next_title="${CHAPTER_TITLES[$((i+1))]}"
  fi

  attach_anchor_to_first_h1 "$f" "${CHAPTER_ANCHORS[$i]}"
  append_navigation_footer "$f" "$prev_anchor" "$prev_title" "$next_anchor" "$next_title"
done

cat > "$METADATA_FILE" <<EOF_META
title: "$TITLE"
author: "$AUTHOR"
language: "$LANG"
publisher: "$PUBLISHER"
rights: "$RIGHTS_TEXT"
description: "$DESCRIPTION_TEXT"
identifier: "$OUTPUT_BASENAME"
EOF_META

ALL_BOOK_FILES=()
for fm in "${FRONTMATTER_FILES[@]}"; do
  ALL_BOOK_FILES+=( "$fm" )
done
for bf in "${BOOK_FILES[@]}"; do
  ALL_BOOK_FILES+=( "$bf" )
done

build_epub() {
  local pandoc_args=(
    --standalone
    --from=markdown+header_attributes+fenced_divs+raw_html+smart
    --to=epub3
    --toc
    --toc-depth=3
    --css="$ASSETS_DIR/epub.css"
    --metadata-file="$METADATA_FILE"
  )

  if [ -f "$COVER_IMAGE" ]; then
    echo "Using cover: $COVER_IMAGE"
    pandoc_args+=(--epub-cover-image="$COVER_IMAGE")
  else
    echo "Warning: cover not found for $LANG → $COVER_IMAGE"
  fi

  echo "Building EPUB..."
  pandoc "${pandoc_args[@]}" "${ALL_BOOK_FILES[@]}" -o "$EPUB_PATH"

  cp "$EPUB_PATH" "$DOWNLOAD_DIR/$(basename "$EPUB_PATH")"
  echo "EPUB created at: $EPUB_PATH"
  echo "Copied to downloads: $DOWNLOAD_DIR"
}

build_pdf_from_epub() {
  command -v ebook-convert >/dev/null 2>&1 || {
    echo "Error: Calibre ebook-convert not found"
    exit 1
  }

  echo "Converting EPUB → PDF using Calibre..."

  ebook-convert "$EPUB_PATH" "$PDF_PATH" \
    --chapter-mark pagebreak \
    --paper-size a4 \
    --margin-top 32 \
    --margin-bottom 32 \
    --margin-left 30 \
    --margin-right 30 \
    --base-font-size 11 \
    --pdf-default-font-size 11 \
    --pdf-mono-font-size 9 \
    --pdf-page-numbers \
    --pdf-page-margin-top 20 \
    --pdf-page-margin-bottom 20 \
    --disable-font-rescaling \
    --minimum-line-height 120

  cp "$PDF_PATH" "$DOWNLOAD_DIR/$(basename "$PDF_PATH")"
  echo "PDF created at: $PDF_PATH"
  echo "Copied to downloads: $DOWNLOAD_DIR"
}

case "$FORMAT" in
  epub)
    build_epub
    ;;
  pdf)
    build_epub
    build_pdf_from_epub
    ;;
  all)
    build_epub
    build_pdf_from_epub
    ;;
esac