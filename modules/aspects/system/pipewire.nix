# Base PipeWire audio stack: pipewire + PulseAudio compat + WirePlumber.
# Host-specific extras (ALSA, Bluetooth WirePlumber config) stay in host aspects.
{
  den.aspects.pipewire = {
    nixos.services.pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      alsa.enable = true;
    };
  };
}
