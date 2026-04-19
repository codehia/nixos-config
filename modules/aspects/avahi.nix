# Avahi — mDNS/DNS-SD for local network service discovery.
{ den, ... }:
{
  den.aspects.avahi = {
    nixos.services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
  };
}
