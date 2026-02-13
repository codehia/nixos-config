{ den, ... }:
{
  den.aspects.deus = {
    includes = [
      den._.primary-user
      (den._.user-shell "fish")
    ];

    nixos =
      { ... }:
      {
        users.users.deus = {
          description = "Soumyaranjan Acharya";
          initialPassword = "REDACTED";
        };
      };

    homeManager =
      { ... }:
      {
        home = {
          homeDirectory = "/home/deus";
          sessionVariables = {
            BROWSER = "zen";
          };
        };
      };
  };
}
