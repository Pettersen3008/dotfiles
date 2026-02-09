if [[ -o interactive ]]; then
  local brew_zfunc="/opt/homebrew/share/zsh/site-functions"
  fpath=("$HOME/.zsh/completions" "$HOME/.docker/completions" $fpath)

  # Homebrew can leave a broken _brew symlink; drop that dir to keep compinit clean.
  if [[ -L "${brew_zfunc}/_brew" && ! -e "${brew_zfunc}/_brew" ]]; then
    fpath=(${fpath:#${brew_zfunc}})
  fi

  # If brew completion moved/vanished, clear stale compdump entries that reference it.
  if [[ ! -e /opt/homebrew/share/zsh/site-functions/_brew ]]; then
    rm -f "${ZDOTDIR:-$HOME}"/.zcompdump*
  fi

  autoload -Uz compinit
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
  compinit -C
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims 2>/dev/null || mise activate zsh)"
fi

# zoxide takes over cd.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
