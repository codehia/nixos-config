# iOS/iPadOS device support: USB pairing, filesystem mounting, firmware restore.
{
  den.aspects.ios-devices = {
    nixos =
      { pkgs, ... }:
      {
        services.usbmuxd.enable = true;

        environment.systemPackages = with pkgs; [
          libimobiledevice
          ifuse
          idevicerestore
        ];
      };
  };
}
