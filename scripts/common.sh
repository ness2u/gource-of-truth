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

    # Find all .git files or directories
    # We prune .git directories themselves so we don't look inside them
    find "$root" -name ".git" -prune -print | sort | while read git_entry; do
        local repo_path="$(dirname "$git_entry")"
        local repo_name="$(basename "$repo_path")"
        
        # Check if any part of the path contains 'work'
        # We check the relative path from the root to ensure we catch 'work' at any level
        # but specifically looking for a 'work' directory in the path.
        if [[ "$repo_path" == *"/work/"* || "$repo_path" == *"/work" || "$repo_name" == "work" ]]; then
            continue
        fi
        
        # Check Ignore List
        if list_contains "$IGNORE_NAMES" "$repo_name"; then
            continue
        fi

        echo "$repo_path"
    done
}
