# Unfree package allowlist — den._.unfree (shorthand for den.provides.unfree)
# takes a list of package names and permits them across all hosts.
{ den, ... }:
{
  den.default.includes = [
    (den._.unfree [
      "1password"
      "1password-cli"
      "1password-gui"
      "slack"
      "spotify"
      "spotify-unwrapped"
      "zoom"
      "zoom-us"
      "discord"
      "vscode"
      "obsidian"
      "mullvad"
      "mullvad-vpn"
      "brave"
      "signal-desktop"
      "google-chrome"
      "unrar"
    ])
  ];
}
