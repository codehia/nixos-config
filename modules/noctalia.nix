# Noctalia shell — all-in-one Wayland shell built on Quickshell.
# Replaces waybar, notifications, lock screen, wallpaper, OSD.
{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.noctalia = username: {
    homeManager = {...}: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia-shell = {
        enable = true;
        # settings = {
        #   predefinedScheme = "Catppuccin";
        # };
      };

      # systemd.user.services.noctalia-shell = {
      #   Unit = {
      #     Description = "Noctalia Shell";
      #     PartOf = ["graphical-session.target"];
      #     Requisite = ["graphical-session.target"];
      #     After = ["graphical-session.target"];
      #   };
      #   Service = {
      #     ExecStart = "/home/${username}/.nix-profile/bin/noctalia-shell";
      #     Restart = "on-failure";
      #     RestartSec = 1;
      #   };
      #   Install = {
      #     WantedBy = ["mango-session.target"];
      #   };
      # };
    };
  };
}
