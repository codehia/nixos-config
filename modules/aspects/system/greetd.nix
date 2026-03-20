# Greeter aspect: tuigreet-backed greetd session manager.
# greetdUser and greetdSessionBin are freeform host attributes (set in hosts.nix).
# The full session path is derived as /home/<greetdUser>/.nix-profile/bin/<greetdSessionBin>.
{ den, ... }:
{
  den.aspects.greetd = {
    includes = [
      (den.lib.perHost (
        { host }:
        let
          user = host.greetdUser;
          session = "/home/${user}/.nix-profile/bin/${host.greetdSessionBin}";
        in
        {
          nixos =
            { pkgs, ... }:
            let
              tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
            in
            {
              services.greetd = {
                enable = true;
                settings = {
                  initial_session = {
                    command = session;
                    inherit user;
                  };
                  default_session = {
                    command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --cmd '${session}'";
                    user = "greeter";
                  };
                };
              };
            };
        }
      ))
    ];
  };
}
