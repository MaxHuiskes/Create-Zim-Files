#!/bin/bash

# Usage:
# sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>

SITE_URL="$1"
OUTPUT_FOLDER="$2"
ZIM_TITLE="$3"
ZIM_DESCRIPTION="$4"
ZIM_CREATOR="$5"

if [[ -z "$SITE_URL" || -z "$OUTPUT_FOLDER" || -z "$ZIM_TITLE" || -z "$ZIM_DESCRIPTION" || -z "$ZIM_CREATOR" ]]; then
    echo "Usage: $0 <site_url> <output_folder> <zim_title> <zim_description> <creator>"
    exit 1
fi

# Create folder for site download
mkdir -p "$OUTPUT_FOLDER/site"

echo "[1] Downloading site: $SITE_URL"
wget --mirror \
     --convert-links \
     --adjust-extension \
     --page-requisites \
     --no-parent \
     --directory-prefix="$OUTPUT_FOLDER/site" \
     "$SITE_URL"

# Find main index.html for welcome page
WELCOME_PAGE=$(find "$OUTPUT_FOLDER/site" -name "index.html" | head -n 1)

echo "[2] Creating ZIM file"
zimwriterfs "$OUTPUT_FOLDER/site" \
           "$OUTPUT_FOLDER/$(basename "$OUTPUT_FOLDER").zim" \
           --title="$ZIM_TITLE" \
           --description="$ZIM_DESCRIPTION" \
           --creator="$ZIM_CREATOR" \
           --welcome="$WELCOME_PAGE" \
           --language=en

echo "[3] Done. ZIM file created at $OUTPUT_FOLDER/$(basename "$OUTPUT_FOLDER").zim"
