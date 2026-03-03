# Niri layout, appearance, and animations.
# Collector pattern: merged into den.aspects.niri by den.
{ ... }:
{
  den.aspects.niri = {
    homeManager =
      { ... }:
      {
        programs.niri.settings = {
          layout = {
            gaps = 7;
            center-focused-column = "never";

            border = {
              enable = true;
              width = 4;
              active.color = "#33ccffee";
              inactive.color = "#595959aa";
            };

            focus-ring.enable = false;

            shadow = {
              enable = true;
              softness = 30;
              color = "#00000070";
            };

            preset-column-widths = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
            ];
            default-column-width = {
              proportion = 1.0 / 2.0;
            };

            tab-indicator = {
              enable = true;
              hide-when-single-tab = true;
            };
          };

          animations = {
            window-open.kind.easing = {
              duration-ms = 200;
              curve = "ease-out-expo";
            };
            window-close.kind.easing = {
              duration-ms = 150;
              curve = "ease-out-quad";
            };
            horizontal-view-movement.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 800;
              epsilon = 0.0001;
            };
            workspace-switch.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 800;
              epsilon = 0.0001;
            };
            window-movement.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 800;
              epsilon = 0.0001;
            };
            window-resize.kind.spring = {
              damping-ratio = 1.0;
              stiffness = 800;
              epsilon = 0.0001;
            };
          };

          cursor = {
            size = 32;
            hide-when-typing = true;
          };

          # Default window rule: rounded corners + clip for Noctalia compatibility.
          window-rules = [
            {
              geometry-corner-radius =
                let
                  r = 7.0;
                in
                {
                  top-left = r;
                  top-right = r;
                  bottom-left = r;
                  bottom-right = r;
                };
              clip-to-geometry = true;
            }
          ];
        };
      };
  };
}
