#!/bin/bash

# Configuration (Customize these!)
OUTPUT_FILE="/src/gource-of-truth/evolution.mp4"
RESOLUTION="1920x1080"
FRAMERATE=60

SKIP_LIST=("ollama-linux-amd-apu")

echo "Starting the Gource of Truth harvest..."

# 1. Generate and prefix logs for all peer directories
LOG_FILE="/tmp/combined_gource.txt"
rm -f $LOG_FILE

for d in /src/*/ ; do
    repo_name=$(basename "$d")
    
    # Check if the repo_name is in our SKIP_LIST
    skip=false
    for skip_item in "${SKIP_LIST[@]}"; do
        if [[ "$repo_name" == "$skip_item" ]]; then
            skip=true
            break
        fi
    done

    # Skip if it's in the list or not a git repo
    if [ "$skip" = true ]; then
        echo "  - Skipping $repo_name (on skip list)"
        continue
    fi

    if [ ! -d "$d/.git" ]; then
        echo "  - Skipping $repo_name (no .git folder)"
        continue
    fi

    echo "Processing: $repo_name"
    # Generate custom log and prefix the path with the repo name
    gource --output-custom-log - "$d" | sed "s/|\//|\/$repo_name\//" >> /tmp/unsorted.txt
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
