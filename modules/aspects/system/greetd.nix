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
                    command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --sessions /run/current-system/sw/share/wayland-sessions --theme 'border=#cba6f7;title=#cba6f7;text=#cdd6f4;prompt=#89b4fa;input=#cdd6f4;greet=#a6e3a1;time=#bac2de;action=#6c7086;button=#cba6f7;container=#1e1e2e'";
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
