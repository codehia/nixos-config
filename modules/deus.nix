{den, ...}: {
  den.aspects.deus = {
    includes = [
      den._.primary-user
      (den._.user-shell "fish")
    ];

    nixos = {...}: {
      users.users.deus = {
        description = "Soumyaranjan Acharya";
        initialPassword = "Soumya$321";
      };
    };

    homeManager = {...}: {
      home = {
        homeDirectory = "/home/deus";
        sessionVariables = {
          BROWSER = "zen";
        };
      };
    };
  };
}
