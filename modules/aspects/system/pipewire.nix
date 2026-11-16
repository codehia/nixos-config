# Base PipeWire audio stack: pipewire + PulseAudio compat + ALSA (WirePlumber comes on with it).
# Bluetooth WirePlumber config lives in bluetooth.nix.
{
  den.aspects.pipewire = {
    nixos.services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
  };
}
