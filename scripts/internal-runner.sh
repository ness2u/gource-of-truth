#!/bin/bash

# Configuration
# Output to a date-stamped file in the output/ directory
DATE_STR=$(date +%Y-%m-%d)
OUTPUT_DIR="/output"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/${DATE_STR}.mp4"

# Ensure we source common.sh from the same directory as this script
source "$(dirname "$0")/common.sh"

echo "Starting the Gource of Truth harvest..."
echo "Scan Root: $SCAN_ROOT"

# 1. Generate and prefix logs for all peer directories
LOG_FILE="/tmp/combined_gource.txt"
rm -f $LOG_FILE
rm -f /tmp/unsorted.txt

# Use get_repos from common.sh
for repo_path in $(get_repos); do
    # Calculate relative path (e.g., projects/wiki)
    # Remove the SCAN_ROOT prefix and leading slash
    relative_path="${repo_path#$SCAN_ROOT}"
    relative_path="${relative_path#/}"
    
    echo "Processing: $relative_path"
    
    # Generate custom log and prefix the path with the hierarchy
    # We replace the root slash in the file path with /relative_path/
    # Gource log format: timestamp|user|type|/path/to/file
    # We want: timestamp|user|type|/projects/wiki/path/to/file
    
    # Escape slashes for sed
    safe_prefix=$(echo "$relative_path" | sed 's/\//\\\//g')
    
    gource --output-custom-log - "$repo_path" | sed "s/|\//|\/$safe_prefix\//" >> /tmp/unsorted.txt
done

# 2. Sort the combined logs chronologically
sort -n /tmp/unsorted.txt > $LOG_FILE

echo "Step 3: Rendering with full detail (this may take a while)..."
START_DATE=${START_DATE:-'2025-01-01'}
RESOLUTION=${RESOLUTION:-'1920x1080'}

xvfb-run -s "-screen 0 ${RESOLUTION}x24" \
    gource $LOG_FILE \
    -${RESOLUTION} \
    --start-date "${START_DATE}" \
    --auto-skip-seconds 1 \
    --seconds-per-day 2 \
    --file-idle-time 0 \
    --filename-time 2 \
    --dir-name-depth 4 \
    --user-scale 1.5 \
    --output-ppm-stream - \
    | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - \
    -vcodec libx264 -pix_fmt yuv420p -crf 18 $OUTPUT_FILE

echo "Video complete: $OUTPUT_FILE"
