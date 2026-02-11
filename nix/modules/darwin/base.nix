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

  system.stateVersion = 5;
}
