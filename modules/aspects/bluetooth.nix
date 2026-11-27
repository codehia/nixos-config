# Bluetooth — hardware config + WirePlumber auto-connect policy for audio profiles.
let
  audioProfiles = [
    "hfp_hf"
    "hsp_hs"
    "a2dp_sink"
  ];
in
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
          "bluez5.auto-connect" = audioProfiles;
          "bluez5.hw-volume" = audioProfiles;
        };
      };
    };
  };
}
