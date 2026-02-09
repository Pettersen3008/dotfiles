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
      "slack"
      "1password"
      "claude"
      "chatgpt"
      "rider"
      "microsoft-teams"
      "docker-desktop"
      "discord"
      "arc"
      "zed"
    ];
  };
}
