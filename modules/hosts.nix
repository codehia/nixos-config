# Host declarations — registers which hosts exist, their architecture, and their users.
# Format: den.hosts.<system>.<hostname>.users.<username> = {};
# Each host declared here gets a NixOS system configuration built for it.
{
  den.hosts.x86_64-linux = {
    thinkpad = {
      home-manager.enable = true;
      isLaptop = true;
      nhCleanEnabled = true;
      greetdUser = "deus";
      greetdSessionBin = "sway";
      nvimLanguages = [
        "lua"
        "nix"
        "python"
        "typescript"
        "go"
        "latex"
      ];
      users.deus = { };
      users.soumya = { };
    };
    personal = {
      home-manager.enable = true;
      gpuKey = "1002:7340-1043:04E6-0000:2d:00.0";
      nhCleanEnabled = true;
      greetdUser = "deus";
      greetdSessionBin = "sway";
      nvimLanguages = [
        "lua"
        "nix"
        "python"
        "typescript"
        "go"
        "latex"
      ];
      users.deus = { };
    };
    workstation = {
      home-manager.enable = true;
      greetdUser = "soumya";
      greetdSessionBin = "start-hyprland";
      nvimLanguages = [
        "lua"
        "nix"
        "python"
      ];
      users.deus = { };
      users.soumya = { };
    };
  };
}
