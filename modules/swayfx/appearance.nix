# SwayFX visual effects — blur, shadows, rounded corners, border colors.
# Merges into the swayfx aspect via the collector pattern.
{...}: {
  den.aspects.swayfx = {
    homeManager = {lib, ...}: {
      wayland.windowManager.sway = {
        config = {
          colors = {
            focused = {
              border = lib.mkForce "#33ccff";
              background = lib.mkForce "#33ccff";
              text = lib.mkForce "#ffffff";
              indicator = lib.mkForce "#33ccff";
              childBorder = lib.mkForce "#33ccff";
            };
            unfocused = {
              border = lib.mkForce "#595959";
              background = lib.mkForce "#1e1e2e";
              text = lib.mkForce "#cdd6f4";
              indicator = lib.mkForce "#595959";
              childBorder = lib.mkForce "#595959";
            };
            focusedInactive = {
              border = lib.mkForce "#595959";
              background = lib.mkForce "#1e1e2e";
              text = lib.mkForce "#cdd6f4";
              indicator = lib.mkForce "#595959";
              childBorder = lib.mkForce "#595959";
            };
            urgent = {
              border = lib.mkForce "#ff5555";
              background = lib.mkForce "#ff5555";
              text = lib.mkForce "#ffffff";
              indicator = lib.mkForce "#ff5555";
              childBorder = lib.mkForce "#ff5555";
            };
          };
        };

        extraConfig = ''
          # SwayFX visual effects (not valid in standard sway)
          corner_radius 7
          blur enable
          blur_passes 3
          blur_radius 5
          shadows enable
          shadow_blur_radius 4
          shadow_color #1a1a1aee
          default_dim_inactive 0.0
        '';
      };
    };
  };
}
