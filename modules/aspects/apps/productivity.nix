{ den, ... }:
{
  den.aspects.apps = {
    includes = [
      (den._.unfree [
        "1password"
        "1password-cli"
        "1password-gui"
        "bitwarden-desktop"
        "bitwarden-cli"
        "obsidian"
      ])
    ];

    homeManager =
      { pkgs, ... }:
      {
        # rbw — Rust Bitwarden CLI. Drives the DankBitwarden DMS launcher plugin
        # (dms/dms-home.nix); bitwarden-cli's `bw` is not a substitute.
        programs.rbw = {
          enable = true;
          settings = {
            email = "soumya@sacharya.dev";
            # rbw literal-matches this URL and derives the identity/notifications/icons
            # endpoints from it (rbw src/config.rs:151) — EU region, not self-hosted.
            base_url = "https://api.bitwarden.eu";
            lock_timeout = 3600;
            # Graphical pinentry required: the plugin runs rbw from quickshell,
            # which has no tty for pinentry-curses to attach to.
            pinentry = pkgs.pinentry-gnome3;
          };
        };

        home.packages =
          (with pkgs; [
            libreoffice-still
            kdePackages.okular
            _1password-gui
            bitwarden-desktop
            bitwarden-cli
            wtype # DankBitwarden types username/password into the focused window
            ente-auth
          ])
          ++ (with pkgs.unstable; [
            obsidian
            # 26.05 siyuan builds with insecure pnpm_9; move back once the pnpm bump is backported
            siyuan
          ]);
      };
  };
}
