setopt no_nomatch
setopt appendhistory hist_ignore_space hist_ignore_dups hist_find_no_dups sharehistory

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=100000
SAVEHIST=100000

export EDITOR="zed --wait"
export VISUAL="code --wait"
export GOPATH="$HOME/go"

path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.opencode/bin"
  "$HOME/.codeium/windsurf/bin"
  "$GOPATH/bin"
  "$HOME/.fly/bin"
  "$HOME/.aspire/bin"
  "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  $path
)
typeset -gU path PATH

[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# Local machine overrides (not committed).
[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
