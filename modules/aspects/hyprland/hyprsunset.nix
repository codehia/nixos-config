{ den, ... }:
{
  den.aspects.hyprland = {
    homeManager.services.hyprsunset = {
      enable = true;
      settings.profile = [
        {
          time = "6:00";
          identity = true;
        }
        {
          time = "18:00";
          temperature = 3000;
          gamma = 0.6;
        }
      ];
    };
  };
}
