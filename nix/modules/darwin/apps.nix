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
    # Safer first-run behavior: do not remove unmanaged apps automatically.
    onActivation.cleanup = "none";
    # Install GUI apps to user space to avoid repeated sudo prompts during cask installs.
    caskArgs.appdir = "/Users/${username}/Applications";

    casks = [
      "raycast"
      "visual-studio-code"
      "warp"
      "google-chrome"
      "jordanbaird-ice"
      "slack"
      "1password"
      "codex"
      "claude"
      "microsoft-teams"
      "docker-desktop"
      "discord"
      "arc"
      "zed"
    ];
  };
}
