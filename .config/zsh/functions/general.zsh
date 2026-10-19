# Cross-platform token resolution.
# Priority: existing env var -> SOPS encrypted file -> optional local fallback file.

load_npm_tokens() {
  # Primary path: encrypted dotenv in repo (same workflow on macOS and Linux).
  if [[ -r "$HOME/.dotfiles/secrets/npm-tokens.sops.env" ]] && command -v sops >/dev/null 2>&1; then
    if [[ -z "${NPM_TOKEN:-}" || -z "${NPM_NEXUM_TOKEN:-}" || -z "${NPM_FORTAWESOME_TOKEN:-}" ]]; then
      local key_file decrypted=""
      for key_file in \
        "${SOPS_AGE_KEY_FILE:-}" \
        "$HOME/.config/sops/age/keys.txt" \
        "$HOME/Library/Application Support/sops/age/keys.txt"
      do
        [[ -n "$key_file" && -r "$key_file" ]] || continue
        decrypted="$(SOPS_AGE_KEY_FILE="$key_file" SOPS_CONFIG="$HOME/.dotfiles/.sops.yaml" sops -d "$HOME/.dotfiles/secrets/npm-tokens.sops.env" 2>/dev/null || true)"
        [[ -n "$decrypted" ]] && break
      done

      if [[ -n "$decrypted" ]]; then
        source <(printf '%s\n' "$decrypted")
        export NPM_TOKEN NPM_NEXUM_TOKEN NPM_FORTAWESOME_TOKEN
      fi
    fi
  fi

  # Optional local fallback file (chmod 600):
  # export NPM_TOKEN=...
  # export NPM_NEXUM_TOKEN=...
  # export NPM_FORTAWESOME_TOKEN=...
  if [[ -r "$HOME/.config/secrets/npm-tokens.env" ]]; then
    source "$HOME/.config/secrets/npm-tokens.env"
  fi

  # Keep npm token vars interoperable for registries that reuse one token.
  [[ -z "${NPM_TOKEN:-}" && -n "${NPM_NEXUM_TOKEN:-}" ]] && export NPM_TOKEN="$NPM_NEXUM_TOKEN"
  [[ -z "${NPM_NEXUM_TOKEN:-}" && -n "${NPM_TOKEN:-}" ]] && export NPM_NEXUM_TOKEN="$NPM_TOKEN"
}

load_npm_tokens

# The Berry repos set enableGlobalCache: false; only an env var beats their .yarnrc.yml
export YARN_ENABLE_GLOBAL_CACHE=true

# Listening TCP ports of your own dev processes, with the tmux session:tab that owns them.
# Only processes started inside a folder under ~ (not ~ itself or ~/Library), so menu-bar apps stay out. Stop one with `kill <pid>`.
ports() {
  local panes=$(tmux list-panes -a -F '#{pane_pid} #S:#I' 2>/dev/null) pid port cwd p tab cmd
  printf '%-6s %-7s %-12s %-26s %s\n' PORT PID COMMAND TMUX DIR
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {sub(/.*:/, "", $9); print $2, $9}' | sort -u |
  while read -r pid port; do
    cwd=$(lsof -a -p $pid -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')
    [[ $cwd == $HOME/* && $cwd != $HOME/Library/* ]] || continue
    p=$pid tab=
    while (( p > 1 )); do
      tab=$(awk -v p=$p '$1 == p {print $2}' <<< $panes)
      [[ -n $tab ]] && break
      p=$(ps -o ppid= -p $p | tr -d ' ')
    done
    cmd=$(basename "$(ps -o comm= -p $pid)")
    printf '%-6s %-7s %-12s %-26s %s\n' $port $pid "${cmd[1,12]}" "${tab:--}" "${cwd/#$HOME/~}"
  done
}

# pin / unpin: add or remove the current repo (or folder) in cmd+P's project list (sesh.toml).
# Paths are stored as ~/... so the list works on both machines.
_sesh_target() {
  local d=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  [[ $d == $HOME/* ]] && reply=(${d:t} "~${d#$HOME}") || reply=(${d:t} $d)
}
pin() {
  local f=~/.config/sesh/sesh.toml; _sesh_target
  grep -qF "path = \"$reply[2]\"" $f && { echo "already pinned: $reply[1]"; return }
  printf '\n[[session]]\nname = "%s"\npath = "%s"\n' $reply >> $f && echo "pinned $reply[1]"
}
unpin() {
  local f=~/.config/sesh/sesh.toml kept; _sesh_target
  # Paragraph mode: each [[session]] block is one record. Write through the symlink, never replace it.
  kept=$(awk -v p="path = \"$reply[2]\"" 'BEGIN { RS = ""; ORS = "\n\n" } index($0, p) == 0' $f)
  print -r -- "$kept" > $f && echo "unpinned $reply[1]"
}
