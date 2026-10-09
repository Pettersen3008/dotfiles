{ username, ... }:
{
  # macOS-only GUI apps live here.
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # Anything not listed here is uninstalled on switch. CLI tools from nixpkgs live in core.nix.
    onActivation.cleanup = "uninstall";
    # Install GUI apps to user space to avoid repeated sudo prompts during cask installs.
    caskArgs.appdir = "/Users/${username}/Applications";

    taps = [
      "docker/tap"
      "joshmedeski/sesh"
    ];

    brews = [
      "bash"
      "coreutils"
      "gawk"
      "libpq" # psql
      "mkcert" # bank-dev local https
      "neovim"
      "tere"
      "tmux"
      "tmuxinator"
      "joshmedeski/sesh/sesh"
      "yarn" # bootstraps each repo's pinned Yarn
    ];

    # Not here on purpose: T3 Code Nightly, Tailscale and OpenVPN Connect were installed outside
    # Homebrew, and Company Portal (Intune) manages Outlook and OneDrive.
    casks = [
      "docker/tap/sbx" # Docker Sandboxes
      "1password"
      "1password-cli"
      "alt-tab"
      "docker-desktop"
      "google-chrome"
      "jordanbaird-ice"
      "microsoft-teams" # drop once Company Portal manages it
      "obsidian" # project-journal skill writes here
      "raycast"
      "slack"
      "warp"
      "font-courier-prime"
      "font-iosevka-etoile"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-monaspice-nerd-font"
      "font-noto-sans-symbols-2"
      "font-symbols-only-nerd-font"
    ];
  };
}
