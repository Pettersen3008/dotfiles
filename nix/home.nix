{ username, ... }:
{
  imports = [
    ./modules/shared/core.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";
}
