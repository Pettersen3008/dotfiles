# Keep keybindings intentionally minimal.
bindkey -e

# Shift+Enter inserts a newline; Enter runs the whole buffer. Ghostty sends ESC[27;2;13~ for Shift+Enter
# (its default modifyOtherKeys encoding), so TUIs that use the kitty protocol keep their own Shift+Enter.
_insert-newline() { LBUFFER+=$'\n' }
zle -N _insert-newline
bindkey '^[[27;2;13~' _insert-newline
bindkey '^[[13;2u' _insert-newline  # Omarchy's Ghostty sends Shift+Enter as CSI u
