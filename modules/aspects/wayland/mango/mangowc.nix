# MangoWC compositor — lightweight Wayland compositor based on dwl.
# Uses the collector pattern: other files (appearance.nix, input.nix, binds.nix) also define
# den.aspects.mangowc and their settings are merged together by den.
{ inputs, ... }:
let
  # Patch MangoWC to use 5 tags instead of the default 9.
  # Tag count is compile-time (src/config/preset.h), so we override the source.
  patchMango =
    pkgs:
    inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/config/preset.h \
          --replace-fail '"1", "2", "3", "4", "5", "6", "7", "8", "9"' \
                         '"1", "2", "3", "4", "5"'
      '';
    });
in
{
  flake-file.inputs.mango = {
    url = "github:DreamMaoMao/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.mangowc = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.mango.nixosModules.mango ];
        programs.mango = {
          enable = true;
          package = patchMango pkgs;
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.mango.hmModules.mango ];

        home.packages = with pkgs; [
          grim
          slurp
          wl-clipboard
          swappy
        ];

        wayland.windowManager.mango = {
          enable = true;
          package = patchMango pkgs;

          # Import all env vars into systemd so services (noctalia, etc.)
          # get PATH, XDG_DATA_DIRS, and other session variables.
          systemd.variables = [ "--all" ];

          autostart_sh = ''
            1password --silent &
            spotify --minimized &
            enteauth &
          '';
        };
      };
  };
}
