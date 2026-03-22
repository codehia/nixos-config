# Host declarations — registers which hosts exist, their architecture, and their users.
# Format: den.hosts.<system>.<hostname>.users.<username> = {};
# Each host declared here gets a NixOS system configuration built for it.
#
# Freeform attributes (wm, extraAspects, sopsFile, etc.) are readable as host.<attr>
# or user.<attr> in aspects. sopsFile paths are explicit — no convention-based derivation.
# Path literal ../secrets resolves at load time, avoiding the self-referential recursion
# that occurs when using `self` in a flake-parts output module.
let
  secrets = ../secrets;
in
{
  den.hosts.x86_64-linux = {
    thinkpad = {
      home-manager.enable = true;
      isLaptop = true;
      nhCleanEnabled = true;
      greetdUser = "deus";
      greetdSessionBin = "sway";
      wm = "swayfx";
      extraAspects = [
        "work"
        "zoom"
        "qbittorrent"
      ];
      nvimLanguages = [
        "lua"
        "nix"
        "python"
        "typescript"
        "go"
        "latex"
      ];
      sopsFile = "${secrets}/thinkpad.yaml";
      users.deus = {
        sopsFile = "${secrets}/deus.yaml";
      };
      users.soumya = {
        sopsFile = "${secrets}/soumya.yaml";
        nvimLanguages = [
          "nix"
          "lua"
          "python"
          "typescript"
        ];
      };
    };
    personal = {
      home-manager.enable = true;
      gpuKey = "1002:7340-1043:04E6-0000:2d:00.0";
      nhCleanEnabled = true;
      greetdUser = "deus";
      greetdSessionBin = "sway";
      wm = "swayfx";
      extraAspects = [ "qbittorrent" ];
      nvimLanguages = [
        "lua"
        "nix"
        "python"
        "typescript"
        "go"
        "latex"
      ];
      sopsFile = "${secrets}/personal.yaml";
      users.deus = {
        sopsFile = "${secrets}/deus.yaml";
      };
    };
    workstation = {
      home-manager.enable = true;
      greetdUser = "soumya";
      greetdSessionBin = "start-hyprland";
      wm = "hyprland";
      extraAspects = [ ];
      nvimLanguages = [
        "lua"
        "nix"
        "python"
      ];
      sopsFile = "${secrets}/workstation.yaml";
      users.deus = {
        sopsFile = "${secrets}/deus.yaml";
      };
      users.soumya = {
        sopsFile = "${secrets}/soumya.yaml";
        nvimLanguages = [
          "nix"
          "lua"
          "python"
          "typescript"
        ];
      };
    };
  };
}
