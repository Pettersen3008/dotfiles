#!/bin/zsh -l
# Ghostty's command: reattach the last tmux session, or pick a project (sesh.toml) when none run.
# Started in another folder (Finder "New Ghostty Window Here"), it opens that folder's session instead.
# Any failure drops to a plain zsh so a window always opens.
if [[ $PWD == $HOME ]]; then
  tmux attach 2>/dev/null || sesh picker -ctdi
else
  sesh connect "$PWD"
fi || exec zsh -l
