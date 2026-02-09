{ pkgs, username, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Determinate manages the Nix installation/daemon; disable nix-darwin's Nix management.
  nix.enable = false;

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
