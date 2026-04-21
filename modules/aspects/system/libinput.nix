{
  den.aspects.libinput = {
    nixos.services.libinput = {
      enable = true;
      touchpad.accelSpeed = "0.5";
    };
  };
}
