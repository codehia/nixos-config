{
  den.aspects.boot = {
    nixos =
      { pkgs, ... }:
      {
        console = {
          font = "ter-v24n";
          packages = [ pkgs.terminus_font ];
          earlySetup = true;
        };

        boot = {
          loader = {
            systemd-boot = {
              enable = true;
              consoleMode = "0";
            };
            efi.canTouchEfiVariables = true;
          };
          plymouth = {
            enable = true;
            theme = "connect";
            themePackages = with pkgs; [
              (adi1090x-plymouth-themes.override {
                selected_themes = [ "connect" ];
              })
            ];
          };
          initrd = {
            verbose = false;
            systemd.enable = true;
          };
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "udev.log_level=3"
            "rd.systemd.show_status=auto"
            "amd_pstate=active"
          ];
          consoleLogLevel = 0;
        };
      };
  };
}
