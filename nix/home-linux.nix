{ username, ... }:
{
  imports = [
    ./modules/shared/core.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
