{ pkgs, ... }:
{
  # Keep git config in dotfiles; avoid Home Manager taking ownership
  # of ~/.config/git while it is symlink-managed by the repo.
  home.packages = with pkgs; [
    git
    git-lfs
  ];
}
