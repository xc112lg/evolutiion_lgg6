#!/bin/bash
#
# apply_commits_safe.sh
#
# Applies each commit from Inkypen79/android_kernel_xiaomi_msm8996 (lineage-23.2)
# to the current git repo (run this from inside the target kernel repo, on the
# branch/commit you want to patch onto).
#
# Behavior:
#   - Downloads and applies each patch with `git am`.
#   - If a patch fails to apply, it aborts that patch (`git am --abort`) and
#     moves on to the next one instead of stopping the whole run.
#   - Every skipped/failed commit is logged to skipped_commits.txt for later review.
#   - Every successfully applied commit is logged to applied_commits.txt.
#   - Safe to re-run: it skips commits already recorded as applied.
#
# Usage:
#   ./apply_commits_safe.sh [hashes_file]
#
#   hashes_file defaults to commit_hashes.txt (one 40-char SHA per line) in the
#   same directory as this script.

set -uo pipefail

REPO_OWNER="Inkypen79"
REPO_NAME="android_kernel_xiaomi_msm8996"
HASHES_FILE="${1:-$(dirname "$0")/commit_hashes.txt}"
APPLIED_LOG="applied_commits.txt"
SKIPPED_LOG="skipped_commits.txt"

if [ ! -f "$HASHES_FILE" ]; then
    echo "Error: hashes file not found: $HASHES_FILE" >&2
    exit 1
fi

if [ ! -d .git ]; then
    echo "Error: not inside a git repository. cd into your target kernel repo first." >&2
    exit 1
fi

touch "$APPLIED_LOG" "$SKIPPED_LOG"

TOTAL=$(wc -l < "$HASHES_FILE")
COUNT=0
APPLIED=0
SKIPPED=0
ALREADY=0

echo "Starting patch run: $TOTAL commits from $REPO_OWNER/$REPO_NAME"
echo "Applied log:  $APPLIED_LOG"
echo "Skipped log:  $SKIPPED_LOG"
echo "----------------------------------------"

while IFS= read -r HASH; do
    # skip blank lines
    [ -z "$HASH" ] && continue

    COUNT=$((COUNT + 1))

    # skip if already applied in a previous run
    if grep -q "^$HASH" "$APPLIED_LOG" 2>/dev/null; then
        ALREADY=$((ALREADY + 1))
        continue
    fi

    echo "[$COUNT/$TOTAL] Applying $HASH ..."

    PATCH_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/commit/${HASH}.patch"

    if curl -sL --fail "$PATCH_URL" | git am --3way >/tmp/git_am_output.$$ 2>&1; then
        SUBJECT=$(git log -1 --pretty=format:'%s' HEAD)
        echo "$HASH | $SUBJECT" >> "$APPLIED_LOG"
        APPLIED=$((APPLIED + 1))
        echo "  -> OK"
    else
        REASON=$(tail -n 5 /tmp/git_am_output.$$ | tr '\n' ' ' | sed 's/"/'"'"'/g')
        echo "$HASH | FAILED | $REASON" >> "$SKIPPED_LOG"
        SKIPPED=$((SKIPPED + 1))
        echo "  -> FAILED, skipping (see $SKIPPED_LOG)"
        # make sure we leave the tree clean for the next patch
        git am --abort >/dev/null 2>&1
    fi
    rm -f /tmp/git_am_output.$$

done < "$HASHES_FILE"

echo "----------------------------------------"
echo "Done."
echo "  Total commits:     $TOTAL"
echo "  Applied this run:  $APPLIED"
echo "  Already applied:   $ALREADY"
echo "  Skipped/failed:    $SKIPPED"
echo ""
echo "See $APPLIED_LOG and $SKIPPED_LOG for details."
