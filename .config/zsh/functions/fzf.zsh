fe() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git . 2>/dev/null \
    | fzf --height 70% --layout=reverse --preview 'bat --style=plain --color=always --line-range :200 {}' --preview-window=right:60%) || return
  "$EDITOR" "$file"
}

fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git . 2>/dev/null \
    | fzf --height 70% --layout=reverse --preview 'eza -la --color=always {} 2>/dev/null || ls -la {}') || return
  cd "$dir" || return
}

frg() {
  local sel file line
  sel=$(rg --line-number --no-heading --smart-case --hidden --glob '!.git' "${1:-}" \
    | fzf --height 80% --layout=reverse --delimiter ':' \
          --preview 'bat --style=plain --color=always --highlight-line {2} {1}' \
          --preview-window=right:60%) || return
  file=$(printf '%s' "$sel" | cut -d: -f1)
  line=$(printf '%s' "$sel" | cut -d: -f2)
  "$EDITOR" +"${line:-1}" "$file"
}
