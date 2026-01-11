#!/bin/bash

# Optional: Override SCAN_ROOT via argument
if [ -n "$1" ]; then
    SCAN_ROOT="$(cd "$1" && pwd)"
fi

# Source the common logic
source "$(dirname "$0")/common.sh"

echo "=== Super Git Push ==="
echo "Pushing repositories in $SCAN_ROOT..."
echo "----------------------------------------"

pushed_count=0
fail_count=0
skip_count=0
synced_count=0

# Arrays to store summary details
skipped_repos=()
failed_repos=()
pushed_repos=()

for repo in $(get_repos); do
    repo_name=$(basename "$repo")
    
    (
        cd "$repo" || exit
        
        # 1. Check for Upstream
        if ! git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
            echo "⚠️  $repo_name: Skipped (No upstream configured)"
            exit 10 # Custom code for skipped
        fi

        # 2. Check Ahead/Behind
        counts=$(git rev-list --left-right --count HEAD...@{u})
        ahead=$(echo $counts | cut -d' ' -f1)
        behind=$(echo $counts | cut -d' ' -f2)

        if [ "$ahead" -eq 0 ]; then
            if [ "$behind" -gt 0 ]; then
                echo "⚠️  $repo_name: Skipped (Behind upstream)"
                exit 10
            else
                echo "   $repo_name: Up to date."
                exit 0 # Synced
            fi
        fi

        if [ "$behind" -gt 0 ]; then
             echo "⚠️  $repo_name: Skipped (Diverged - pull/merge first)"
             exit 10
        fi

        # 3. Check for Dirty State
        if [ -n "$(git status --porcelain)" ]; then
            echo "⚠️  $repo_name: Skipped (Dirty/Uncommitted changes)"
            exit 10
        fi

        # 4. Attempt Push
        echo "🚀 $repo_name: Pushing (+$ahead commits)..."
        output=$(git push 2>&1)
        status=$?

        if [ $status -eq 0 ]; then
            echo "✅ $repo_name: Pushed!"
            exit 2 # Custom code for pushed
        else
            echo "❌ $repo_name: Failed to push."
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
    elif [ $ret -eq 2 ]; then
        pushed_count=$((pushed_count + 1))
        pushed_repos+=("$repo_name")
    else
        synced_count=$((synced_count + 1))
    fi

done

echo ""
echo "=== Summary ==="
echo "✅ Pushed:      $pushed_count"
echo "🔄 Up to date:  $synced_count"
echo "⚠️ Skipped:     $skip_count"
echo "❌ Failed:      $fail_count"

if [ ${#pushed_repos[@]} -gt 0 ]; then
    echo ""
    echo "Pushed Repos:"
    for r in "${pushed_repos[@]}"; do echo " - $r"; done
fi

if [ ${#skipped_repos[@]} -gt 0 ]; then
    echo ""
    echo "Skipped Repos (Dirty, No Upstream, or Diverged):"
    for r in "${skipped_repos[@]}"; do echo " - $r"; done
fi

if [ ${#failed_repos[@]} -gt 0 ]; then
    echo ""
    echo "Failed Repos (Check manually):"
    for r in "${failed_repos[@]}"; do echo " - $r"; done
fi
