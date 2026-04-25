# hypridle — idle management for Hyprland.
# Pauses media on lock and before sleep.
{ den, ... }:
{
  den.aspects.hyprland = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.playerctl ];

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              before_sleep_cmd = "${pkgs.playerctl}/bin/playerctl -a pause";
              after_sleep_cmd = "${pkgs.systemd}/bin/systemctl --user restart hyprsunset.service";
              on_lock_cmd = "${pkgs.playerctl}/bin/playerctl -a pause";
            };
          };
        };
      };
  };
}
