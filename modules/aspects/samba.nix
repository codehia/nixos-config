{ den, ... }:
{
  den.aspects.samba = {
    nixos =
      { config, ... }:
      {
        services.samba = {
          enable = true;
          openFirewall = false;
          nmbd.enable = false;
          settings = {
            global = {
              "hosts allow" = "100.64.0.0/10 127.0.0.1 ::1 192.168.50.0/24";
              "hosts deny" = "ALL";
              # No guest access: iOS (and Windows 10+/macOS) refuse anonymous
              # SMB2 sessions outright, so a guest share is unusable from VLC
              # on iPhone. Clients must authenticate as a real Samba user.
              "map to guest" = "never";
              "server min protocol" = "SMB2";
            };
            public = {
              "path" = "/home/deus/Public";
              "browseable" = "yes";
              "read only" = "no";
              "valid users" = "deus";
              "create mask" = "0644";
              "directory mask" = "0755";
            };
          };
        };

        services.avahi.extraServiceFiles.smb = ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';

        # Port is opened on all interfaces; access control is Samba's
        # "hosts allow"/"hosts deny" above (Tailnet + LAN only).
        # Opening only on tailscale0 breaks LAN clients (iOS VLC, Thunar),
        # which surface the dropped connect as a credentials prompt.
        networking.firewall.allowedTCPPorts = [ 445 ];
      };
  };
}
