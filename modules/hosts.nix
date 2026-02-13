# Host declarations — registers which hosts exist, their architecture, and their users.
# Format: den.hosts.<system>.<hostname>.users.<username> = {};
# Each host declared here gets a NixOS system configuration built for it.
{...}: {
  den.hosts.x86_64-linux.thinkpad.users.deus = {};
}
