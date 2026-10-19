{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      # Two-line frame per command, the closest a plain terminal gets to Warp blocks. No full-width $fill rule:
      # any line as wide as the pane wraps when it narrows (tmux zoom, splits) and leaves broken prompt lines.
      # The blank line between commands comes from zsh (completions.zsh) so tmux's prompt mark lands on this line.
      add_newline = false;
      command_timeout = 1000;
      format = "[╭─](bright-black) $directory$git_branch$git_status$cmd_duration$status$line_break[╰─](bright-black)$character";
      directory.style = "bold blue";
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "purple";
      };
      git_status.format = "[$all_status$ahead_behind]($style) ";
      cmd_duration.format = " [$duration]($style) ";
      status = {
        disabled = false;
        format = "[✗ $status]($style) ";
      };
      character = {
        success_symbol = "[>](bold green) ";
        error_symbol = "[>](bold red) ";
      };
    };
  };
}
