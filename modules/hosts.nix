# Host declarations — registers which hosts exist, their architecture, and their users.
# Format: den.hosts.<system>.<hostname>.users.<username> = {};
# Each host declared here gets a NixOS system configuration built for it.
{
  den.hosts.x86_64-linux = {
    thinkpad = {
      home-manager.enable = true;
      isLaptop = true;
      users.deus = { };
      users.soumya = { };
    };
    personal = {
      home-manager.enable = true;
      users.deus = { };
    };
    workstation = {
      home-manager.enable = true;
      users.deus = { };
      users.soumya = { };
    };
  };
}
