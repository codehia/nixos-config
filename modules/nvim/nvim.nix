{ inputs, ... }:
let
  wlib = inputs.wrappers.lib;
in
{
  flake-file.inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

  den.aspects.nvim.homeManager =
    { pkgs, ... }:
    let
      nvimPkg =
        inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;
    in
    {
      home.packages = [
        (wlib.evalPackage [
          { inherit pkgs; }
          (
            { pkgs, wlib, ... }:
            {
              imports = [ wlib.wrapperModules.neovim ];
              package = nvimPkg;
              settings.aliases = [ "vim" ];
              settings.config_directory = ./.;
              settings.block_normal_config = true;
              extraPackages = import ./_lsps.nix { inherit pkgs; };
              specs = import ./_plugins.nix { inherit pkgs; };
              info = {
                nixdExtras.nixpkgs = "import ${pkgs.path} {}";
                categories = {
                  general = true;
                  lua = true;
                  nix = true;
                  python = true;
                  typescript = true;
                  go = false;
                };
              };
              hosts.python3.nvim-host.enable = true;
              hosts.node.nvim-host.enable = true;
            }
          )
        ])
      ];
    };
}
