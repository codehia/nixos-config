# Kanata keyboard remapping — Kinesis Advantage 360 config.
# uinput prerequisites (kernel module, group, udev rule) come from the kanata
# module itself via hardware.uinput.enable.
{ den, ... }:
{
  den.aspects.kanata = {
    nixos = {
      services.kanata = {
        enable = true;
        keyboards.kinesis = {
          devices = [
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          configFile = ./kinesis.kbd;
        };
      };
    };
  };
}
