{ username, config, ... }:
{
  imports = [
    ./modules/shared/core.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  home.file.".local/bin/prune-repos".source = ../scripts/prune-repos.sh;

  # Weekly: trash clones in ~/Github/tfso idle for 30 days. Log: ~/Library/Logs/prune-repos.log
  launchd.agents.prune-repos = {
    enable = true;
    config = {
      ProgramArguments = [ "${config.home.homeDirectory}/.local/bin/prune-repos" "--apply" ];
      StartCalendarInterval = [ { Weekday = 1; Hour = 10; Minute = 17; } ];
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/prune-repos.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/prune-repos.log";
    };
  };
}
