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
              "guest account" = "nobody";
              "map to guest" = "bad user";
            };
            public = {
              "path" = "/home/deus/Public";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "yes";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = "deus";
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

        networking.firewall.interfaces.tailscale0 = {
          allowedTCPPorts = [ 445 ];
          allowedUDPPorts = [
            137
            138
          ];
        };
      };
  };
}
