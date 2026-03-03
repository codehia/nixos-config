{ ... }:
{
  den.aspects.cli-utils = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # archives
          zip
          xz
          unzip
          p7zip
          unrar

          # file utilities
          file
          which
          tree
          gnused
          gnutar
          gawk
          zstd

          # notifications
          libnotify

          # networking
          mtr
          iperf3
          dnsutils
          ldns
          aria2
          socat
          nmap
          ipcalc
        ];
      };
  };
}
