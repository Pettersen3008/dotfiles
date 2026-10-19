{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      # Blank line + full-width header rule per command: the closest a plain terminal gets to Warp blocks.
      add_newline = true;
      command_timeout = 1000;
      format = "$directory$git_branch$git_status$fill$cmd_duration$status$line_break$character";
      directory.style = "bold blue";
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "purple";
      };
      git_status.format = "[$all_status$ahead_behind]($style) ";
      fill = {
        symbol = "─";
        style = "bright-black";
      };
      cmd_duration.format = " [$duration]($style) ";
      status = {
        disabled = false;
        format = "[✗ $status]($style) ";
      };
      character = {
        success_symbol = "[->](bold green) ";
        error_symbol = "[->](bold red) ";
      };
    };
  };
}
