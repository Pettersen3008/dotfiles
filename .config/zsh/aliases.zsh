alias c='clear'
alias cleanup='$HOME/.dotfiles/nix/scripts/declutter.sh'
alias ls='eza --icons=auto --group-directories-first'
alias l='eza --icons=auto --group-directories-first'
alias la='eza -la --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto'
alias v='zed --wait'
alias catp='bat --paging=never --style=plain'

# Socket Firewall — intercept package installs
alias npm='sfw npm'
alias yarn='sfw yarn'
alias pnpm='sfw pnpm'
