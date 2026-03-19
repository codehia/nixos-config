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
{ inputs, ... }:
{
  flake-file.inputs.pam-fde-boot-pw = {
    url = "git+https://git.sr.ht/~kennylevinsen/pam_fde_boot_pw";
    flake = false;
  };

  den.aspects.gnome-keyring = {
    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      let
        pam-fde-boot-pw = pkgs.stdenv.mkDerivation {
          pname = "pam-fde-boot-pw";
          version = "0.1";
          src = inputs.pam-fde-boot-pw;
          nativeBuildInputs = [
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
          ];
          buildInputs = [
            pkgs.pam
            pkgs.keyutils
          ];
        };
      in
      {
        services = {
          dbus.packages = with pkgs; [
            gnome-keyring
            gcr
          ];
          gnome.gnome-keyring.enable = true;
        };

        security.pam.services = {
          greetd.enableGnomeKeyring = true;
          greetd-password.enableGnomeKeyring = true;
          login.enableGnomeKeyring = true;
          # Keep keyring password in sync when the login password changes.
          passwd.enableGnomeKeyring = true;
        };

        # Inject the LUKS passphrase into the PAM session just before
        # pam_gnome_keyring runs (which is at order 12700).
        security.pam.services.greetd.rules.session.fde_boot_pw = {
          order = 12600;
          enable = true;
          control = "optional";
          modulePath = "${pam-fde-boot-pw}/lib/security/pam_fde_boot_pw.so";
          args = [ "inject_for=gkr" ];
        };

        # Allow greetd to access the kernel keyring inherited from systemd,
        # where the LUKS passphrase was stored during initrd boot.
        systemd.services.greetd.serviceConfig.KeyringMode = lib.mkForce "inherit";
      };
  };
}
