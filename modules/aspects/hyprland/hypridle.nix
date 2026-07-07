# hypridle — idle management for Hyprland.
# Pauses media on lock and before sleep.
{ den, ... }:
{
  den.aspects.hyprland = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = [ pkgs.playerctl ];

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              before_sleep_cmd = "${pkgs.playerctl}/bin/playerctl -a pause";
              on_lock_cmd = "${pkgs.playerctl}/bin/playerctl -a pause";
            };
          };
        };

        # Only start under Hyprland — every user has all WM HM configs active, and the
        # unit's graphical-session.target fires under every compositor. Each WM imports
        # XDG_CURRENT_DESKTOP into the user manager on session start.
        # mkForce: the HM module itself sets ConditionEnvironment = "WAYLAND_DISPLAY";
        # keep it in the list (systemd requires all conditions to pass).
        systemd.user.services.hypridle.Unit.ConditionEnvironment = lib.mkForce [
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP=Hyprland"
        ];
      };
  };
}
