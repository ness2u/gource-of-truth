#!/bin/bash

# Source the common logic
source "$(dirname "$0")/common.sh"

echo "=== Super Git Pull ==="
echo "Updating repositories in $SCAN_ROOT..."
echo "----------------------------------------"

success_count=0
fail_count=0
skip_count=0

# Arrays to store summary details
skipped_repos=()
failed_repos=()
updated_repos=()

for repo in $(get_repos); do
    repo_name=$(basename "$repo")
    
    (
        cd "$repo" || exit
        
        # 1. Check for Dirty State
        if [ -n "$(git status --porcelain)" ]; then
            echo "⚠️  $repo_name: Skipped (Dirty/Uncommitted changes)"
            exit 10 # Custom code for skipped
        fi

        # 2. Check for Upstream
        if ! git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
            echo "⚠️  $repo_name: Skipped (No upstream configured)"
            exit 10
        fi

        # 3. Attempt Pull
        echo "⬇️  $repo_name: Pulling..."
        output=$(git pull 2>&1)
        status=$?

        if [ $status -eq 0 ]; then
            if [[ "$output" == *"Already up to date."* ]]; then
                echo "   $repo_name: Already up to date."
                exit 0
            else
                echo "✅ $repo_name: Updated!"
                exit 0 # Code for updated (we treat up-to-date as success too, but we track actual updates)
            fi
        else
            echo "❌ $repo_name: Failed to pull."
            echo "$output"
            exit 1 # Code for failure
        fi
    )
    
    # Capture exit code from subshell
    ret=$?
    
    if [ $ret -eq 10 ]; then
        skip_count=$((skip_count + 1))
        skipped_repos+=("$repo_name")
    elif [ $ret -eq 1 ]; then
        fail_count=$((fail_count + 1))
        failed_repos+=("$repo_name")
    else
        success_count=$((success_count + 1))
        # We could differentiate actual updates vs "already up to date" if we wanted closer parsing
    fi

done

echo ""
echo "=== Summary ==="
echo "✅ Success: $success_count"
echo "⚠️ Skipped: $skip_count"
echo "❌ Failed:  $fail_count"

if [ ${#skipped_repos[@]} -gt 0 ]; then
    echo ""
    echo "Skipped Repos (Dirty or No Upstream):"
    for r in "${skipped_repos[@]}"; do echo " - $r"; done
fi

if [ ${#failed_repos[@]} -gt 0 ]; then
    echo ""
    echo "Failed Repos (Check manually):"
    for r in "${failed_repos[@]}"; do echo " - $r"; done
fi
