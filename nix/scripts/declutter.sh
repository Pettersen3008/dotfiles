#!/usr/bin/env bash
set -euo pipefail

APPLY=0
INCLUDE_DIRTY_REPOS=0
CHECK_REPOS=1
CHECK_SCREENSHOTS=1
CHECK_DOWNLOADS=1

REPOS_ROOT="${HOME}/Github"
REPO_DAYS=120
SCREENSHOT_DAYS=45
DOWNLOAD_DAYS=30
TRASH_DIR="${HOME}/.Trash"

NOW_EPOCH="$(date +%s)"

usage() {
  cat <<USAGE
Usage: declutter [options]

Safely declutter old repos/screenshots/downloads by moving candidates to Trash.
Default mode is dry-run (no files are moved).

Options:
  --apply                    Move candidates to Trash
  --repos-root PATH          Repo root (default: ~/Github)
  --repo-days N              Mark repos stale after N days (default: 120)
  --screenshot-days N        Mark screenshots stale after N days (default: 45)
  --downloads-days N         Mark downloads stale after N days (default: 30)
  --include-dirty-repos      Include repos with uncommitted changes
  --no-repos                 Skip repo cleanup
  --no-screenshots           Skip screenshot cleanup
  --no-downloads             Skip Downloads cleanup
  -h, --help                 Show this help

Examples:
  declutter
  declutter --repo-days 180 --downloads-days 14
  declutter --apply
USAGE
}

is_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

stat_mtime_epoch() {
  local p="$1"
  if stat -f "%m" "$p" >/dev/null 2>&1; then
    stat -f "%m" "$p"
  else
    stat -c "%Y" "$p"
  fi
}

size_kb() {
  du -sk "$1" 2>/dev/null | awk '{print $1+0}'
}

human_kb() {
  local kb="${1:-0}"
  local unit="KB"
  local val="$kb"
  if (( kb >= 1048576 )); then
    unit="GB"
    val=$((kb / 1048576))
  elif (( kb >= 1024 )); then
    unit="MB"
    val=$((kb / 1024))
  fi
  printf "%s%s" "$val" "$unit"
}

age_days_from_epoch() {
  local epoch="$1"
  if (( epoch <= 0 )); then
    echo 99999
  else
    echo $(((NOW_EPOCH - epoch) / 86400))
  fi
}

declare -a ITEM_TYPES=()
declare -a ITEM_PATHS=()
declare -a ITEM_AGES=()
declare -a ITEM_SIZES=()
declare -a ITEM_REASONS=()
declare -a SKIPPED_DIRTY_REPOS=()

add_item() {
  ITEM_TYPES+=("$1")
  ITEM_PATHS+=("$2")
  ITEM_AGES+=("$3")
  ITEM_SIZES+=("$4")
  ITEM_REASONS+=("$5")
}

collect_repos() {
  [[ -d "$REPOS_ROOT" ]] || return 0

  local gitdir repo dirty last_commit last_reflog last_activity age size
  while IFS= read -r -d '' gitdir; do
    repo="${gitdir%/.git}"
    [[ -d "$repo" ]] || continue

    if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      continue
    fi

    if (( INCLUDE_DIRTY_REPOS == 0 )); then
      dirty="$(git -C "$repo" status --porcelain --untracked-files=no 2>/dev/null || true)"
      if [[ -n "$dirty" ]]; then
        SKIPPED_DIRTY_REPOS+=("$repo")
        continue
      fi
    fi

    last_commit="$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)"
    last_reflog="$(git -C "$repo" reflog -1 --date=unix --format=%cd 2>/dev/null || echo 0)"

    last_activity="$last_commit"
    if is_int "$last_reflog" && (( last_reflog > last_activity )); then
      last_activity="$last_reflog"
    fi

    if ! is_int "$last_activity" || (( last_activity <= 0 )); then
      last_activity="$(stat_mtime_epoch "$repo")"
    fi

    age="$(age_days_from_epoch "$last_activity")"
    if (( age >= REPO_DAYS )); then
      size="$(size_kb "$repo")"
      add_item "repo" "$repo" "$age" "$size" "inactive >= ${REPO_DAYS}d"
    fi
  done < <(find "$REPOS_ROOT" -type d -name .git -prune -print0 2>/dev/null)
}

collect_screenshots() {
  local p age size

  if [[ -d "${HOME}/Desktop" ]]; then
    while IFS= read -r -d '' p; do
      age="$(age_days_from_epoch "$(stat_mtime_epoch "$p")")"
      size="$(size_kb "$p")"
      add_item "screenshot" "$p" "$age" "$size" "older than ${SCREENSHOT_DAYS}d"
    done < <(
      find "${HOME}/Desktop" -maxdepth 1 -type f \
        \( -name 'Screenshot *' -o -name 'Screen Shot *' -o -name 'Skjermbilde *' \) \
        -mtime +"${SCREENSHOT_DAYS}" -print0 2>/dev/null
    )
  fi

  if [[ -d "${HOME}/Pictures/Screenshots" ]]; then
    while IFS= read -r -d '' p; do
      age="$(age_days_from_epoch "$(stat_mtime_epoch "$p")")"
      size="$(size_kb "$p")"
      add_item "screenshot" "$p" "$age" "$size" "older than ${SCREENSHOT_DAYS}d"
    done < <(
      find "${HOME}/Pictures/Screenshots" -type f -mtime +"${SCREENSHOT_DAYS}" -print0 2>/dev/null
    )
  fi
}

collect_downloads() {
  local p age size
  [[ -d "${HOME}/Downloads" ]] || return 0

  while IFS= read -r -d '' p; do
    age="$(age_days_from_epoch "$(stat_mtime_epoch "$p")")"
    size="$(size_kb "$p")"
    add_item "download" "$p" "$age" "$size" "older than ${DOWNLOAD_DAYS}d"
  done < <(
    find "${HOME}/Downloads" -mindepth 1 -maxdepth 1 \
      ! -name '.DS_Store' \
      -mtime +"${DOWNLOAD_DAYS}" -print0 2>/dev/null
  )
}

print_plan() {
  local total=0
  local i

  if (( ${#ITEM_PATHS[@]} == 0 )); then
    echo "No cleanup candidates found with current thresholds."
    return 0
  fi

  echo "Candidates:"
  printf "%-11s %-8s %-8s %s\n" "TYPE" "AGE" "SIZE" "PATH"
  printf "%-11s %-8s %-8s %s\n" "----------" "-------" "-------" "----"

  for i in "${!ITEM_PATHS[@]}"; do
    printf "%-11s %-8s %-8s %s\n" \
      "${ITEM_TYPES[$i]}" \
      "${ITEM_AGES[$i]}d" \
      "$(human_kb "${ITEM_SIZES[$i]}")" \
      "${ITEM_PATHS[$i]}"
    total=$((total + ITEM_SIZES[i]))
  done

  echo
  echo "Estimated reclaimable: $(human_kb "$total")"

  if (( ${#SKIPPED_DIRTY_REPOS[@]} > 0 )); then
    echo "Skipped dirty repos: ${#SKIPPED_DIRTY_REPOS[@]} (use --include-dirty-repos to include)"
  fi
}

move_to_trash() {
  local src="$1"
  local base dest stamp

  [[ -e "$src" ]] || return 0
  mkdir -p "$TRASH_DIR"

  base="$(basename "$src")"
  dest="${TRASH_DIR}/${base}"

  if [[ -e "$dest" ]]; then
    stamp="$(date +%Y%m%d-%H%M%S)"
    dest="${TRASH_DIR}/${base}.${stamp}"
  fi

  mv "$src" "$dest"
}

apply_plan() {
  local i moved=0
  for i in "${!ITEM_PATHS[@]}"; do
    move_to_trash "${ITEM_PATHS[$i]}"
    moved=$((moved + 1))
  done
  echo "Moved ${moved} item(s) to ${TRASH_DIR}."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=1
      ;;
    --repos-root)
      shift
      REPOS_ROOT="${1:-}"
      ;;
    --repo-days)
      shift
      REPO_DAYS="${1:-}"
      ;;
    --screenshot-days)
      shift
      SCREENSHOT_DAYS="${1:-}"
      ;;
    --downloads-days)
      shift
      DOWNLOAD_DAYS="${1:-}"
      ;;
    --include-dirty-repos)
      INCLUDE_DIRTY_REPOS=1
      ;;
    --no-repos)
      CHECK_REPOS=0
      ;;
    --no-screenshots)
      CHECK_SCREENSHOTS=0
      ;;
    --no-downloads)
      CHECK_DOWNLOADS=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

for n in "$REPO_DAYS" "$SCREENSHOT_DAYS" "$DOWNLOAD_DAYS"; do
  if ! is_int "$n"; then
    echo "Day thresholds must be integers." >&2
    exit 1
  fi
done

if (( CHECK_REPOS == 1 )); then
  collect_repos
fi
if (( CHECK_SCREENSHOTS == 1 )); then
  collect_screenshots
fi
if (( CHECK_DOWNLOADS == 1 )); then
  collect_downloads
fi

print_plan

if (( APPLY == 0 )); then
  echo
  echo "Dry-run only. Re-run with --apply to move candidates to Trash."
else
  echo
  apply_plan
fi
