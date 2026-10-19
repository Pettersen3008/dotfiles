# Terminal: Ghostty + tmux + sesh

Ghostty is the window, tmux holds one session per project, sesh picks projects, zsh + starship draw framed prompts.

## Files

| File | Role | macOS | Omarchy |
|---|---|---|---|
| `.config/ghostty/dotfiles.conf` | Shared behavior: start command, bar cursor, shell integration | linked as `ghostty/config` | linked as `ghostty/dotfiles.conf`, included by Omarchy's `ghostty/config` |
| `.config/ghostty/macos.conf` / `linux.conf` | Look and keys | linked as `ghostty/os.conf` | linked as `ghostty/os.conf` (keys only) |
| `.config/tmux/tmux.conf` | macOS base config and TokyoNight look | linked | not used; Omarchy ships its own |
| `.config/tmux/dotfiles.conf` | Shared bindings: picker, blocks, extended keys | sourced by `tmux.conf` | sourced by Omarchy's `tmux.conf` |
| `.config/sesh/sesh.toml` | Pinned projects for the picker | linked | linked |
| `scripts/term-start.sh` | Ghostty's command: reattach, else picker | `~/.local/bin/term-start` | same |
| `.config/zsh/completions.zsh` | Prompt gap and OSC 133 marks inside tmux | | |

Omarchy owns `~/.config/ghostty/config` and `~/.config/tmux/tmux.conf`: its migrations rewrite them in place,
which would replace a symlink. Those files stay Omarchy's and end with one include line each:

```
# ~/.config/ghostty/config
config-file = ?"~/.config/ghostty/dotfiles.conf"

# ~/.config/tmux/tmux.conf
source-file -q ~/.config/tmux/dotfiles.conf
```

tmux comes from nix on macOS and from pacman on Omarchy, so each machine has one tmux.
The shared tmux file binds only prefix keys that are free in both setups (`o O u j y`); Ghostty sends them with `C-b`,
which is Omarchy's secondary prefix.

## Keys

| Action | macOS | Omarchy |
|---|---|---|
| Pinned projects / any project | ⌘P / ⌘⇧P | Ctrl+Shift+P / Ctrl+Alt+P |
| All sessions and tabs | ⌘O | Ctrl+Shift+O |
| Previous / next command | ⌘↑ / ⌘↓ | Ctrl+Shift+↑ / ↓ |
| Copy last command's output | ⌘⇧C | Ctrl+Shift+Y |
| Zoom split | ⌘⇧Enter | Ctrl+Shift+Enter |
| New tab, close, splits | ⌘T, ⌘W, ⌘D / ⌘⇧D, ⌘⇧+arrows | Omarchy's tmux keys (Alt+Enter, Alt+1-9, Ctrl+Alt+arrows) |
| Newline without running | Shift+Enter | Shift+Enter |

Shell: `pin` / `unpin` the current repo in the picker, `ports` lists listening dev ports with their tmux tab.
