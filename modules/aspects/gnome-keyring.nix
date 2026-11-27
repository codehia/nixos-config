# Gnome Keyring aspect — enables keyring service and auto-unlocks it
# using the LUKS passphrase stored in the kernel keyring during boot.
#
# pam_fde_boot_pw retrieves the LUKS passphrase from the kernel keyring and
# injects it into the PAM session so pam_gnome_keyring can unlock the keyring
# without any user interaction — even with greetd autologin.
#
# One-time requirement: the gnome-keyring "login" keyring password must already
# match the LUKS passphrase (set via seahorse or on keyring creation).
# Requires boot.initrd.systemd.enable = true.
{
  den.aspects.gnome-keyring = {
    nixos =
      { pkgs, lib, ... }:
      {
        # Also registers the gnome-keyring + gcr D-Bus services and the `login` PAM hook.
        services.gnome.gnome-keyring.enable = true;

        security.pam = {
          services = {
            greetd = {
              enableGnomeKeyring = true;
              # Inject the LUKS passphrase into the PAM session just before
              # pam_gnome_keyring runs (which is at order 12600 in NixOS 26.05+).
              rules.session.fde_boot_pw = {
                order = 12500;
                enable = true;
                control = "optional";
                modulePath = "${pkgs.pam_fde_boot_pw}/lib/security/pam_fde_boot_pw.so";
                args = [ "inject_for=gkr" ];
              };
            };
            greetd-password.enableGnomeKeyring = true;
            # Keep keyring password in sync when the login password changes.
            passwd.enableGnomeKeyring = true;
          };
        };

        # Allow greetd to access the kernel keyring inherited from systemd,
        # where the LUKS passphrase was stored during initrd boot.
        systemd.services.greetd.serviceConfig.KeyringMode = lib.mkForce "inherit";
      };
  };
}
