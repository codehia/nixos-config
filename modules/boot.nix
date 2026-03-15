{ ... }:
{
  den.aspects.boot = {
    nixos =
      { pkgs, ... }:
      {
        boot = {
          loader = {
            systemd-boot = {
              enable = true;
              consoleMode = "2";
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
            kernelModules = [ "amdgpu" ];
          };
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "udev.log_level=3"
            "udev.log_priority=3"
            "rd.systemd.show_status=auto"
            "amd_pstate=active"
          ];
          kernelModules = [ "uinput" ];
          consoleLogLevel = 0;
        };
      };
  };
}
