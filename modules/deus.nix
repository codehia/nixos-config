# User aspect — defines the "deus" user identity.
#
# den._.primary-user:     Marks this user as the primary user for each host (used by other aspects).
# den._.user-shell "fish": Sets fish as the login shell and ensures it's available.
{den, ...}: {
  den.aspects.deus = {
    includes = [den._.primary-user (den._.user-shell "fish")];

    nixos = {...}: {
      users.users.deus = {
        description = "Soumyaranjan Acharya";
        initialPassword = "REDACTED";
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
