# River-classic compositor with wideriver layout generator.
# Uses the collector pattern: binds.nix, input.nix, appearance.nix, scratchpad.nix
# also define den.aspects.river and their attrs are merged together by den.
#
# To activate: replace den.aspects.swayfx with den.aspects.river in thinkpad.nix
# and change greetd session to "river".
{ ... }:
{
  den.aspects.river = {
    nixos =
      { pkgs, ... }:
      {
        programs.river-classic = {
          enable = true;
          xwayland.enable = true;
          extraPackages = with pkgs; [
            wideriver
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home = {
          packages = with pkgs; [
            wl-clipboard
            grim
            slurp
            swappy
            wideriver
          ];
          sessionVariables.NIXOS_OZONE_WL = "1";
        };

        wayland.windowManager.river = {
          enable = true;
          xwayland.enable = true;
          systemd = {
            enable = true;
            variables = [ "--all" ];
          };

          settings = {
            default-layout = "wideriver";
          };

          extraConfig = ''
            # ── Server-side decorations ──
            riverctl rule-add ssd

            # ── Start wideriver layout generator ──
            wideriver \
              --layout wide \
              --layout-alt monocle \
              --stack dwindle \
              --count-master 1 \
              --ratio-master 0.50 \
              --ratio-wide 0.35 \
              --count-wide-left 0 \
              --inner-gaps 7 \
              --outer-gaps 0 \
              --smart-gaps \
              --border-width 4 \
              --border-width-monocle 0 \
              --border-width-smart-gaps 0 \
              --border-color-focused 0x89b4fa \
              --border-color-focused-monocle 0x89b4fa \
              --border-color-unfocused 0x45475a \
              &

            # ── Startup apps ──
            riverctl spawn "1password --silent"
            riverctl spawn spotify
            riverctl spawn enteauth
          '';
        };
      };
  };
}
