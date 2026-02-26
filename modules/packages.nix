{...}: {
  den.aspects.packages = {
    homeManager = {pkgs, ...}: {
      home.packages =
        (with pkgs; [
          inkscape
          cowsay
          fortune
          # archives
          zip
          xz
          unzip
          p7zip

          # utils
          ripgrep
          jq
          yq-go
          eza
          fzf

          # networking tools
          mtr
          iperf3
          dnsutils
          ldns
          aria2
          socat
          nmap
          ipcalc

          # misc
          file
          which
          tree
          gnused
          gnutar
          gawk
          zstd
          gnupg

          # nix related
          nix-output-monitor

          # productivity
          hugo
          glow

          htop
          btop
          iotop
          iftop

          # system call monitoring
          strace
          ltrace
          lsof

          # system tools
          sysstat
          lm_sensors
          ethtool
          pciutils
          usbutils

          kitty

          fish
          xfce.thunar
          xfce.thunar-volman
          nixfmt-classic
          just

          # SECRETS
          age
          ssh-to-age

          slack
          vlc

          qbittorrent
          brightnessctl
          fastfetch
          ente-auth
          _1password-gui
          _1password-cli

          pulsemixer
          bluetui
          spotify
          ncdu

          libglvnd
          libglibutil
          zoom-us

          libreoffice-still

          telegram-desktop
          signal-desktop-bin

          obs-studio

          calibre
          unrar

          kdePackages.okular
          gearlever
        ])
        ++ (with pkgs.unstable; [
          ghostty
          devenv
          obsidian
          vscode
          claude-code
        ]);
    };
  };
}
