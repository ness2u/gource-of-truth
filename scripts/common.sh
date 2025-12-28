#!/bin/bash

# common.sh
# Shared utilities for Gource of Truth tools.

# Load config
# Assuming this script is in ./scripts/ and config is in ./
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/got.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Warning: got.conf not found at $CONFIG_FILE. Using defaults."
    SCAN_ROOT="../"
    IGNORE_NAMES=""
fi

# Function to check if an item is in a space-separated list
list_contains() {
    local list="$1"
    local item="$2"
    for word in $list; do
        if [[ "$word" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get a list of git repositories
get_repos() {
    local root="${SCAN_ROOT%/}" # Remove trailing slash if present
    
    # If explicit includes are set (and not empty), use those (expanding relative to root if needed)
    # For now, we'll stick to scanning ROOT.

    # Find directories in SCAN_ROOT
    for d in "$root"/*/; do
        [ -d "$d" ] || continue # Handle empty glob
        
        local repo_path="${d%/}"
        local repo_name=$(basename "$repo_path")

        # Check Ignore List
        if list_contains "$IGNORE_NAMES" "$repo_name"; then
            continue
        fi

        # Check if it is actually a git repo
        if [ -d "$repo_path/.git" ]; then
            echo "$repo_path"
        fi
    done
}
