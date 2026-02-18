# MangoWC compositor — lightweight Wayland compositor based on dwl.
# Uses the collector pattern: other files (appearance.nix, input.nix, binds.nix) also define
# den.aspects.mangowc and their settings are merged together by den.
{inputs, ...}: {
  flake-file.inputs.mango = {
    url = "github:DreamMaoMao/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.mangowc = {
    nixos = {...}: {
      imports = [inputs.mango.nixosModules.mango];
      programs.mango = {enable = true;};
    };

    homeManager = {pkgs, ...}: {
      imports = [inputs.mango.hmModules.mango];

      home.packages = with pkgs; [grim slurp wl-clipboard swappy];

      wayland.windowManager.mango = {
        enable = true;

        autostart_sh = ''
          noctalia-shell &
          1password --silent &
          spotify --minimized &
          mullvad-gui &
          enteauth &
        '';
      };
    };
  };
}
