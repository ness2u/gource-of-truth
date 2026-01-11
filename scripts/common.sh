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

    # Use find to locate directories containing .git
    # -maxdepth 3 allows: root/category/project/.git
    find "$root" -maxdepth 3 -name ".git" -type d | sort | while read gitdir; do
        local repo_path="$(dirname "$gitdir")"
        local repo_name="$(basename "$repo_path")"
        local category_dir="$(dirname "$repo_path")"
        local category_name="$(basename "$category_dir")"

        # Ignore 'work' category explicitly as per mandates
        if [[ "$category_name" == "work" || "$repo_name" == "work" ]]; then
            continue
        fi
        
        # Check Ignore List
        if list_contains "$IGNORE_NAMES" "$repo_name"; then
            continue
        fi

        echo "$repo_path"
    done
}
