# User aspect — defines the "soumya" user identity.
{ den, ... }:
{
  den.aspects.soumya = {
    includes = [
      den._.primary-user
      (den._.user-shell "fish")
    ];

    nixos =
      { ... }:
      {
        users.users.soumya = {
          description = "Soumyaranjan Acharya";
          initialPassword = "Soumya$321";
        };
      };

    homeManager =
      { ... }:
      {
        home.homeDirectory = "/home/soumya";
        programs.git.settings.user = {
          name = "Soumyaranjan Acharya";
          email = "";
        };
      };
  };
}
