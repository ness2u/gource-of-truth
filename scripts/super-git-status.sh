#!/bin/bash

# Optional: Override SCAN_ROOT via argument
if [ -n "$1" ]; then
    SCAN_ROOT="$(cd "$1" && pwd)"
fi

# Source the common logic
source "$(dirname "$0")/common.sh"

echo "=== Super Git Status ==="
echo "Scanning repositories in $SCAN_ROOT..."
echo "----------------------------------------"

# Loop through repos found by common.sh
for repo in $(get_repos); do
    repo_name=$(basename "$repo")
    
    # Subshell to handle cd without affecting main script
    (
        cd "$repo" || exit
        
        # 1. Check for local changes (Dirty)
        if [ -n "$(git status --porcelain)" ]; then
            local_status="DIRTY 📝"
        else
            local_status="Clean ✨"
        fi

        # 2. Check Ahead/Behind (needs an upstream)
        # We wrap in a check to avoid errors if no upstream is configured
        remote_status=""
        if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
            # distinct counts: left=local, right=remote
            counts=$(git rev-list --left-right --count HEAD...@{u})
            ahead=$(echo $counts | cut -d' ' -f1)
            behind=$(echo $counts | cut -d' ' -f2)

            if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
                remote_status="DIVERGED 🔀 (+$ahead / -$behind)"
            elif [ "$ahead" -gt 0 ]; then
                remote_status="AHEAD 🚀 (+$ahead)"
            elif [ "$behind" -gt 0 ]; then
                remote_status="BEHIND 🐢 (-$behind)"
            else
                remote_status="Synced 🔄"
            fi
        else
            remote_status="No Upstream ⚠️"
        fi

        # Pretty Print
        # Align output
        printf "% -25s | % -15s | %s\n" "$repo_name" "$local_status" "$remote_status"
    )
done
