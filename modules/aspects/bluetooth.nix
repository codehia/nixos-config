# Bluetooth — hardware config + WirePlumber auto-connect policy for audio profiles.
{ den, ... }:
{
  den.aspects.bluetooth = {
    nixos = {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
            FastConnectable = true;
          };
          Policy = {
            AutoEnable = true;
            ReconnectAttempts = 7;
            ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
          };
        };
      };
      services.pipewire.wireplumber.extraConfig.bluetoothPolicy = {
        "monitor.bluez.properties" = {
          "bluez5.auto-connect" = [
            "hfp_hf"
            "hsp_hs"
            "a2dp_sink"
          ];
          "bluez5.hw-volume" = [
            "hfp_hf"
            "hsp_hs"
            "a2dp_sink"
          ];
        };
      };
    };
  };
}
