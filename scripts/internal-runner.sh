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
    repo_name=$(basename "$repo_path")
    echo "Processing: $repo_name"
    
    # Generate custom log and prefix the path with the repo name
    # We use repo_path directly
    gource --output-custom-log - "$repo_path" | sed "s/|\//|\/$repo_name\//" >> /tmp/unsorted.txt
done

# 2. Sort the combined logs chronologically
sort -n /tmp/unsorted.txt > $LOG_FILE

echo "Step 3: Rendering with full detail (this may take a while)..."
xvfb-run -s "-screen 0 1920x1080x24" \
    gource $LOG_FILE \
    -1920x1080 \
    --start-date '2025-01-01' \
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
