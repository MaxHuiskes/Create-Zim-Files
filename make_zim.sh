#!/bin/bash

# make_zim.sh
# Script to download a website and convert it into a ZIM file for Kiwix

# Usage:
# sudo ./make_zim.sh <site_url> <output_folder> <zim_title> <zim_description> <creator>

set -e

# Arguments
SITE_URL="$1"
OUTPUT_FOLDER="$2"
ZIM_TITLE="$3"
ZIM_DESCRIPTION="$4"
CREATOR="$5"

# Check arguments
if [ -z "$SITE_URL" ] || [ -z "$OUTPUT_FOLDER" ] || [ -z "$ZIM_TITLE" ] || [ -z "$ZIM_DESCRIPTION" ] || [ -z "$CREATOR" ]; then
    echo "Usage: $0 <site_url> <output_folder> <zim_title> <zim_description> <creator>"
    exit 1
fi

# Create temporary working directory
TMP_DIR=$(mktemp -d)
echo "Using temporary folder: $TMP_DIR"

# Download website recursively
echo "Downloading website from $SITE_URL..."
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P "$TMP_DIR" "$SITE_URL"

# Ensure output folder exists
mkdir -p "$OUTPUT_FOLDER"

# Generate ZIM file
ZIM_FILENAME="$OUTPUT_FOLDER/$(basename "$SITE_URL" | sed 's/[^a-zA-Z0-9]/_/g').zim"
echo "Creating ZIM file: $ZIM_FILENAME"

zimwriterfs \
    --title="$ZIM_TITLE" \
    --description="$ZIM_DESCRIPTION" \
    --creator="$CREATOR" \
    "$TMP_DIR" "$ZIM_FILENAME"

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "Done. ZIM file saved at: $ZIM_FILENAME"
