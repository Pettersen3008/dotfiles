{ pkgs, ... }:
{
  imports = [
    ./mise.nix
    ./git.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  # Shared baseline for macOS + Linux; keep it small and high-value.
  home.packages = with pkgs;
    [
      mise
      jq
      just
      nano
      gh
      dotnet-sdk
      ripgrep
      fd
      fzf
      bat
      zoxide
      eza
      gitleaks
      age
      sops
    ];

  home.sessionVariables = {
    EDITOR = "nano";
    VISUAL = "nano";
    SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
  };

  home.file.".local/bin/declutter".source = ../../scripts/declutter.sh;
}
