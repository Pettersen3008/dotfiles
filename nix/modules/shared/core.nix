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
      sesh
    ]
    # Linux already has GNU tools and a current bash.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      bashInteractive
      coreutils-prefixed # g-prefixed like Homebrew's, so BSD ls/cp stay default
      gawk
      tmux # Omarchy installs its own with pacman; one tmux per machine avoids client/server version mismatches
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      lsof # `ports` zsh function; macOS ships it
    ];

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
  };

  home.file.".zshrc".source = dot ".zshrc";
  xdg.configFile."git".source = dot ".config/git";
  xdg.configFile."mise/config.toml".source = dot ".config/mise/config.toml";
  xdg.configFile."sesh/sesh.toml".source = dot ".config/sesh/sesh.toml";
  # Shared tmux/Ghostty behavior. On Omarchy, its own tmux.conf and ghostty/config stay in place (its migrations
  # rewrite them, which would break a symlink) and include these files on their last line.
  xdg.configFile."tmux/dotfiles.conf".source = dot ".config/tmux/dotfiles.conf";
  xdg.configFile."ghostty/dotfiles.conf".source = dot ".config/ghostty/dotfiles.conf";
  xdg.configFile."ghostty/os.conf".source =
    dot (if pkgs.stdenv.hostPlatform.isDarwin then ".config/ghostty/macos.conf" else ".config/ghostty/linux.conf");
  # Vicinae rewrites settings.json from its GUI, so only this import is shared; settings.json lists it in "imports".
  xdg.configFile."vicinae/shared.json".source = dot ".config/vicinae/shared.json";

  home.file.".local/bin/declutter".source = ../../scripts/declutter.sh;
  home.file.".local/bin/term-start".source = dot "scripts/term-start.sh";
}
