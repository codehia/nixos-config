# Greeter aspect: tuigreet-backed greetd session manager.
# greetdUser and greetdSessionBin are freeform host attributes (set in hosts.nix).
# The full session path is derived as /home/<greetdUser>/.nix-profile/bin/<greetdSessionBin>.
{ den, inputs, ... }:
{
  flake-file.inputs.tuigreet = {
    url = "github:NotAShelf/tuigreet";
    inputs.nixpkgs.follows = "nixpkgs";
  };
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
              tuigreet = "${inputs.tuigreet.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/tuigreet";
            in
            {
              # /var/cache/tuigreet is required by --remember and --remember-user-session flags.
              systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0750 greeter greeter -" ];

              services.greetd = {
                enable = true;
                settings = {
                  initial_session = {
                    command = session;
                    inherit user;
                  };
                  default_session = {
                    # ANSI 16-color names used — hex/truecolor is not supported on Linux VT.
                    command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --sessions /etc/wayland-sessions --theme 'border=magenta;title=magenta;text=white;prompt=bright-blue;input=white;greet=cyan;time=gray;action=gray;button=magenta;container=black'";
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
