{ pkgs, username, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Let nix-darwin manage Nix installation/daemon lifecycle.
  nix.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
  system.primaryUser = username;

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;
  programs.zsh.enableBashCompletion = false;

  environment.systemPackages = with pkgs; [
    git
    curl
  ];

  # GUI apps (T3, editors) get it too; see .config/zsh/functions/general.zsh
  launchd.user.envVariables.YARN_ENABLE_GLOBAL_CACHE = "true";

  system.stateVersion = 5;
}
