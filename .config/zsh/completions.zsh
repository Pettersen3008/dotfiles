if [[ -o interactive ]]; then
  fpath=("$HOME/.zsh/completions" "$HOME/.docker/completions" $fpath)

  autoload -Uz compinit
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
  # -C trusts the dump; a full compinit once a day picks up new or removed completions
  if [[ $(date +%j) == $(date -r "${ZDOTDIR:-$HOME}/.zcompdump" +%j 2>/dev/null) ]]; then
    compinit -C
  else
    compinit && touch "${ZDOTDIR:-$HOME}/.zcompdump"
  fi
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims 2>/dev/null || mise activate zsh)"
fi

# zoxide takes over cd. Not in Claude Code shells: its snapshot keeps the cd function but drops the hook, so zoxide's doctor warns on every command.
if [[ -z "${CLAUDECODE:-}" ]] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if [[ -o interactive ]] && [[ "${TERM:-}" != "dumb" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
