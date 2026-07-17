#!/bin/bash
# am-force-theirs.sh
# Starts (if needed) a `git am --3way` from a given commit's .patch URL,
# then loops through the series, force-resolving any conflict by taking
# the incoming patch's version ("theirs") and continuing.
#
# Usage:
#   ./am-force-theirs.sh <repo_path> <patch_url>
#
# Example:
#   ./am-force-theirs.sh /tmp/src/android/kk/android_kernel_lge_msm8996_r2 \
#     https://github.com/LineageOS/android_kernel_lge_msm8996/commit/4631bada94ae79e3a12c51eb74c751b14fed3b80.patch

set -uo pipefail

REPO="${1:?Usage: $0 <repo_path> <patch_url>}"
PATCH_URL="${2:?Usage: $0 <repo_path> <patch_url>}"
LOG="/tmp/am-force-theirs.log"
> "$LOG"

# If no am session is active, start one from the given patch URL
if [ ! -d "$REPO/.git/rebase-apply" ]; then
  echo "No am session in progress. Fetching and starting: $PATCH_URL" | tee -a "$LOG"
  if curl -sL "$PATCH_URL" | git -C "$REPO" am --3way >> "$LOG" 2>&1; then
    echo "Series applied cleanly with no conflicts." | tee -a "$LOG"
    echo "=== Done. Run 'git -C \"$REPO\" log --oneline -35' to verify. ===" | tee -a "$LOG"
    exit 0
  fi
  echo "am hit a conflict on the first patch — entering force-theirs loop." | tee -a "$LOG"
fi

echo "=== Starting force-theirs resolution loop in $REPO ===" | tee -a "$LOG"

while true; do
  if [ ! -d "$REPO/.git/rebase-apply" ]; then
    echo "No am session remaining. Series complete." | tee -a "$LOG"
    break
  fi

  unmerged=$(git -C "$REPO" diff --name-only --diff-filter=U)

  if [ -z "$unmerged" ]; then
    echo "No unmerged files detected, attempting 'git am --continue'..." | tee -a "$LOG"
    if git -C "$REPO" am --continue >> "$LOG" 2>&1; then
      continue
    else
      echo "'git am --continue' failed with no unmerged files. See $LOG." | tee -a "$LOG"
      git -C "$REPO" status >> "$LOG" 2>&1
      exit 1
    fi
  fi

  echo "Conflicted files:" | tee -a "$LOG"
  echo "$unmerged" | tee -a "$LOG"

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    git -C "$REPO" checkout --theirs -- "$f" >> "$LOG" 2>&1
    git -C "$REPO" add -- "$f" >> "$LOG" 2>&1
  done <<< "$unmerged"

  echo "Continuing am..." | tee -a "$LOG"
  if git -C "$REPO" am --continue >> "$LOG" 2>&1; then
    echo "Patch committed." | tee -a "$LOG"
  else
    echo "am --continue failed after forcing theirs. See $LOG." | tee -a "$LOG"
    git -C "$REPO" status >> "$LOG" 2>&1
    exit 1
  fi
done

echo "=== Done. Run 'git -C \"$REPO\" log --oneline -35' to verify. ===" | tee -a "$LOG"
