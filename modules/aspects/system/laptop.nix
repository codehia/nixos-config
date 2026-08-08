# Laptop bundle — power management and input aspects for laptop hosts.
{ den, ... }:
{
  den.aspects.laptop = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.brightnessctl ];
        # Install brightnessctl's udev rule so /sys/class/backlight/*/brightness
        # becomes group-writable by `video`. Without this, DMS/brightnessctl fall
        # back to logind SetBrightness, which is session-activation dependent and
        # fails until DMS is restarted.
        services.udev.packages = [ pkgs.brightnessctl ];
      };

    includes = [
      den.aspects.tlp
      den.aspects.upower
      den.aspects.libinput
    ];
  };
}
