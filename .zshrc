# Thin loader for modular zsh config.
# Order matters.
for f in \
  "$HOME/.dotfiles/.config/zsh/shelloptions.zsh" \
  "$HOME/.dotfiles/.config/zsh/completions.zsh" \
  "$HOME/.dotfiles/.config/zsh/functions/general.zsh" \
  "$HOME/.dotfiles/.config/zsh/functions/fzf.zsh" \
  "$HOME/.dotfiles/.config/zsh/aliases.zsh" \
  "$HOME/.dotfiles/.config/zsh/keys.zsh"
do
  [[ -r "$f" ]] && source "$f"
done

# bun completions
[ -s "/Users/pettersen/.bun/_bun" ] && source "/Users/pettersen/.bun/_bun"

# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# mise shims must win over vite-plus node
export PATH="$HOME/.local/share/mise/shims:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/pettersen/.local/bin:$PATH"

# One Claude config for terminal and T3, so mcp/sync.sh in the skills repo covers both
export CLAUDE_CONFIG_DIR="$HOME/.claude"
