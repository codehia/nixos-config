# Kanata keyboard remapping — Kinesis Advantage 360 config.
# Includes uinput/udev prerequisites that kanata depends on.
# enable = false by default; flip to true when remapping is needed.
{ den, ... }:
{
  den.aspects.kanata = {
    nixos = {
      services.kanata = {
        enable = false;
        keyboards.kinesis = {
          devices = [
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-event-if02"
            "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd"
          ];
          extraDefCfg = "process-unmapped-keys yes";
          configFile = ./kinesis.kbd;
        };
      };
      services.udev.extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';
      hardware.uinput.enable = true;
      systemd.services.kanata-internalKeyboard.serviceConfig.SupplementaryGroups = [
        "input"
        "uinput"
      ];
    };
  };
}
