# Music arr stack — Lidarr (library/grab) + Prowlarr (indexers) +
# slskd (Soulseek, for rare/niche) + Navidrome (stream the library).
# All run as system services. A shared `media` group lets every service and
# deus read-write one library tree so hardlinks work across the arr pipeline.
{ den, ... }:
let
  mediaDir = "/var/lib/media";
  musicDir = "${mediaDir}/music";
  dlDir = "${mediaDir}/downloads";
in
{
  den.aspects.music-arr = {
    nixos =
      { pkgs, ... }:
      {
        users.groups.media = { };
        users.users.lidarr.extraGroups = [ "media" ];
        users.users.slskd.extraGroups = [ "media" ];
        users.users.navidrome.extraGroups = [ "media" ];
        # deus runs qBittorrent (home-manager) — needs write to the shared dl dir.
        users.users.deus.extraGroups = [ "media" ];

        # setgid dirs so new files inherit the media group.
        systemd.tmpfiles.rules = [
          "d ${mediaDir}      2775 root   media - -"
          "d ${musicDir}      2775 lidarr media - -"
          "d ${dlDir}         2775 lidarr media - -"
          "d ${dlDir}/slskd   2775 slskd  media - -"
          "d ${dlDir}/qbit    2775 deus   media - -"
        ];

        services.prowlarr.enable = true; # web :9696, localhost only

        services.lidarr = {
          enable = true; # web :8686
          group = "media";
        };

        services.slskd = {
          enable = true;
          openFirewall = true; # opens soulseek listen port only (50300)
          domain = null;
          # TEMP hardcoded creds — world-readable in /nix/store. Replace with the
          # sops slskd_env secret (see bottom) before real use / before committing.
          environmentFile = pkgs.writeText "slskd-env" ''
            SLSKD_SLSK_USERNAME=username
            SLSKD_SLSK_PASSWORD=password
            SLSKD_USERNAME=username
            SLSKD_PASSWORD=password
          '';
          settings = {
            shared.directories = [ musicDir ];
            directories.downloads = "${dlDir}/slskd";
            soulseek.listen_port = 50300;
            web.port = 5030;
          };
        };

        services.navidrome = {
          enable = true;
          settings = {
            Address = "127.0.0.1";
            Port = 4533;
            MusicFolder = musicDir;
          };
        };

        # LATER: swap the hardcoded environmentFile above for this sops secret.
        # sops.secrets.slskd_env = {
        #   sopsFile = ../../secrets/common.yaml;
        # };
      };

    # GUI / CLI music tools for deus (manual search + download).
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          nicotine-plus # Soulseek GUI client — manual browse/search/download
          streamrip # CLI lossless grab from Qobuz/Tidal/Deezer/SoundCloud
          spotdl # download Spotify playlists via YouTube match
          yt-dlp # audio from YouTube/SoundCloud/Bandcamp
          beets # MusicBrainz-backed tagger/organizer
        ];
      };
  };
}
