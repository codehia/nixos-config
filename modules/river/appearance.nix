# River appearance — border colors (Catppuccin Mocha), border-width.
# Merges into the river aspect via the collector pattern.
#
# Catppuccin Mocha base16 reference:
#   base00 = 0x1e1e2e (Base)        base08 = 0xf38ba8 (Red)
#   base03 = 0x45475a (Surface 1)   base0D = 0x89b4fa (Blue)
{ ... }:
{
  den.aspects.river = {
    homeManager =
      { ... }:
      {
        wayland.windowManager.river.settings = {
          border-width = 4;
          background-color = "0x1e1e2e";
          border-color-focused = "0x89b4fa";
          border-color-unfocused = "0x45475a";
          border-color-urgent = "0xf38ba8";
        };
      };
  };
}
