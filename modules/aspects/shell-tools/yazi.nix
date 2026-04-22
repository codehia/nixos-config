# yazi — terminal file manager with preview support.
# Catppuccin Mocha theming via catppuccin/nix (stylix target disabled in appearance.nix).
# Shell wrapper "y" changes cwd on exit.
{ den, ... }:
{
  den.aspects.shell-tools = {
    homeManager =
      { pkgs, ... }:
      {
        programs.yazi = {
          enable = true;
          enableFishIntegration = true;
          shellWrapperName = "y";
          settings = {
            manager = {
              show_hidden = false;
              sort_by = "natural";
              sort_sensitive = false;
            };
          };
        };

        home.packages = with pkgs; [
          ffmpegthumbnailer # video thumbnails
          unar # archive previews
          poppler-utils # PDF previews
          exiftool # file metadata
          fd # file search
          imagemagick # image conversion fallback
        ];
      };
  };
}
