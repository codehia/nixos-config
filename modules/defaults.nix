# Global defaults — config applied to every host and user.
# den.default sets baseline NixOS and home-manager options across all hosts.
{ den, ... }:
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
    includes = [
      den._.mutual-provider
      den.provides.define-user
      den.provides.hostname
      den.provides.inputs'
    ];
  };
}
