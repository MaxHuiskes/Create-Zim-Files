#!/bin/bash

# make_zim.sh
# Script to download a website and convert it into a ZIM file for Kiwix

# Usage:
# sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>

set -e

SITE_URL="$1"
OUTPUT_FOLDER="$2"
ZIM_TITLE="$3"
ZIM_DESCRIPTION="$4"
CREATOR="$5"

if [ -z "$SITE_URL" ] || [ -z "$OUTPUT_FOLDER" ] || [ -z "$ZIM_TITLE" ] || [ -z "$ZIM_DESCRIPTION" ] || [ -z "$CREATOR" ]; then
    echo "Usage: $0 <site_url> <output_folder> <zim_title> <zim_description> <creator>"
    exit 1
fi

TMP_DIR=$(mktemp -d)
echo "Using temporary folder: $TMP_DIR"

echo "Downloading website from $SITE_URL..."
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P "$TMP_DIR" "$SITE_URL"

mkdir -p "$OUTPUT_FOLDER"

# Determine directory name created by wget
DOMAIN=$(echo "$SITE_URL" | awk -F/ '{print $3}')
HTML_DIR="$TMP_DIR/$DOMAIN"

if [ ! -d "$HTML_DIR" ]; then
    echo "Error: expected directory not found at $HTML_DIR"
    exit 1
fi

# Ensure an illustration exists (48x48 PNG)
echo "Creating illustration..."
convert -size 48x48 xc:white "$HTML_DIR/illustration.png"

ZIM_FILENAME="$OUTPUT_FOLDER/$(echo "$DOMAIN" | sed 's/[^a-zA-Z0-9]/_/g').zim"
echo "Creating ZIM file: $ZIM_FILENAME"

zimwriterfs \
    --welcome="index.html" \
    --illustration="illustration.png" \
    --language="eng" \
    --title="$ZIM_TITLE" \
    --description="$ZIM_DESCRIPTION" \
    --longDescription="$ZIM_DESCRIPTION" \
    --creator="$CREATOR" \
    --publisher="$CREATOR" \
    --name="$(basename "$SITE_URL" | sed 's/[^a-zA-Z0-9]/_/g')" \
    "$HTML_DIR" "$ZIM_FILENAME"

echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "Done. ZIM file saved at: $ZIM_FILENAME"
