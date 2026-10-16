{ pkgs, lib, config, ... }:
let
  # Live links into the repo: edits apply without a rebuild, and mise can write its config.
  dot = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/${path}";
in
{
  imports = [
    ./git.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  # Shared baseline for macOS + Linux; keep it small and high-value.
  # Runtimes and agent CLIs live in mise (.config/mise/config.toml), which installs itself.
  home.packages = with pkgs;
    [
      jq
      just
      gh
      ripgrep
      fd
      fzf
      bat
      zoxide
      eza
      gitleaks
      age
      sops
      postgresql # psql
      mkcert # bank-dev local https
      neovim
      tere
    ]
    # Linux already has GNU tools and a current bash.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      bashInteractive
      coreutils-prefixed # g-prefixed like Homebrew's, so BSD ls/cp stay default
      gawk
    ];

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
  };

  home.file.".zshrc".source = dot ".zshrc";
  xdg.configFile."git".source = dot ".config/git";
  xdg.configFile."mise/config.toml".source = dot ".config/mise/config.toml";

  home.file.".local/bin/declutter".source = ../../scripts/declutter.sh;
}
