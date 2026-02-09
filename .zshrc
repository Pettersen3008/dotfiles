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
