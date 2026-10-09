#!/usr/bin/env bash
# Move clones in ~/Github/tfso nobody has touched for DAYS to the Trash. Dry run unless --apply.
# Activity = newest of checkout/commit/pull (.git/logs/HEAD), fetch (.git/FETCH_HEAD) and edited files.
# Local changes and unpushed commits are trashed too. Keeps repos with no origin (cannot be re-cloned),
# repos with linked worktrees, and names in KEEP.
set -euo pipefail

DAYS=${DAYS:-30}
apply=false
[[ "${1:-}" == "--apply" ]] && apply=true
KEEP=(react-layout-components)
root=${PRUNE_ROOT:-$HOME/Github/tfso}
now=$(date +%s)
cutoff=$((now - DAYS * 86400))
trashed=()

newest() { stat -f %m "$@" 2>/dev/null | sort -n | tail -1 || true; }

for repo in "$root"/*/; do
  repo=${repo%/}
  [[ -L "$repo" || ! -d "$repo/.git" ]] && continue # links and linked worktrees (.git file)
  g() { git -C "$repo" --no-optional-locks "$@"; }

  last=$(newest "$repo/.git/HEAD" "$repo/.git/logs/HEAD" "$repo/.git/FETCH_HEAD")
  ((last < cutoff)) || continue
  # editing files without running git still counts as work
  edited=$(cd "$repo" && g ls-files -z -m -o --exclude-standard | xargs -0 stat -f %m 2>/dev/null | sort -n | tail -1 || true)
  ((${edited:-0} > last)) && last=$edited
  ((last < cutoff)) || continue

  reason=""
  [[ " ${KEEP[*]} " == *" $(basename "$repo") "* ]] && reason="KEEP"
  [[ -z "$reason" ]] && ! g remote get-url origin >/dev/null 2>&1 && reason="no origin, local only"
  [[ -z "$reason" && $(g worktree list | wc -l) -gt 1 ]] && reason="linked worktrees"

  idle=$(((now - last) / 86400))
  if [[ -n "$reason" ]]; then
    echo "keep    ${repo/#$HOME/~} (idle ${idle}d, ${reason})"
  elif ! $apply; then
    echo "would   ${repo/#$HOME/~} (idle ${idle}d, $(du -sh "$repo" | cut -f1))"
  elif trash "$repo"; then
    echo "trashed ${repo/#$HOME/~} (idle ${idle}d)"
    trashed+=("$(basename "$repo")")
  else
    echo "FAILED  ${repo/#$HOME/~}"
  fi
done

echo "$(date '+%F %T') done, trashed ${#trashed[@]}"
if $apply && ((${#trashed[@]})); then
  osascript -e "display notification \"${trashed[*]}\" with title \"prune-repos: ${#trashed[@]} repo(er) i papirkurven\"" || true
fi
