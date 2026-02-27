{...}: {
  den.aspects.services = {
    homeManager = {...}: {
      services = {
        gnome-keyring.enable = true;
        dunst.enable = false;
        hyprsunset = {
          enable = true;
          settings = {
            profile = [
              {
                time = "6:00";
                identity = true;
              }
              {
                time = "18:30";
                temperature = 3000;
                gamma = 0.6;
              }
            ];
          };
        };
      };
    };
  };
}
