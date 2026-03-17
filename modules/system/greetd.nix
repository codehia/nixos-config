# Greeter aspect: tuigreet-backed greetd session manager.
# Parameters:
#   username — the auto-login and greeter user
#   session  — path to the compositor/session binary
_: {
  den.aspects.greetd =
    { username, session }:
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
                user = username;
              };
              default_session = {
                command = "${tuigreet} --greeting 'Welcome to NixOs!' --asterisks --remember --remember-user-session --time --cmd '${session}'";
                user = "greeter";
              };
            };
          };
        };
    };
}
