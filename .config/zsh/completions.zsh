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

# Blank line between commands, skipped before the first prompt.
_prompt_gap() { [[ -n ${_prompt_drawn:-} ]] && print; _prompt_drawn=1 }
precmd_functions+=(_prompt_gap)

# Ghostty's shell integration doesn't load inside tmux; mark prompt and output starts (OSC 133) so tmux can jump.
# The prompt mark lives in PS1 (zle's redraw would erase one printed from precmd), after the gap line.
if [[ -n ${TMUX:-} ]]; then
  PS1=$'%{\e]133;A\e\\%}'$PS1
  _osc133_output() { print -n '\e]133;C\e\\' }
  preexec_functions+=(_osc133_output)
fi
