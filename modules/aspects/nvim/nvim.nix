{
  inputs,
  lib,
  den,
  ...
}:
let
  wlib = inputs.wrappers.lib;

  nvimPerUser =
    {
      host,
      user,
      ...
    }:
    let
      languages =
        user.nvimLanguages or host.nvimLanguages or [
          "lua"
          "nix"
        ];
    in
    {
      homeManager =
        { pkgs, ... }:
        let
          nvimPkg = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;

          lzextrasLatest = inputs.lzextras.packages.${pkgs.stdenv.hostPlatform.system}.lzextras-vimPlugin;

          langDefs = import ./_lang-defs.nix { inherit pkgs; };
          enabledLangs = [ "general" ] ++ languages;

          # Collect packages from all enabled languages
          runtimePkgs = lib.concatMap (l: langDefs.${l}.packages) enabledLangs;

          # Merge formatter maps (fast and slow) across enabled languages
          mergeFmtMaps =
            speed:
            lib.foldl' (
              acc: l: lib.recursiveUpdate acc (langDefs.${l}.formatters.${speed} or { })
            ) { } enabledLangs;

          fastFormatters = mergeFmtMaps "fast";
          slowFormatters = mergeFmtMaps "slow";

          # Merge linter maps across enabled languages
          linters = lib.foldl' (
            acc: l: lib.recursiveUpdate acc (langDefs.${l}.linters or { })
          ) { } enabledLangs;

          # Build categories attrset from languages list
          categories = lib.listToAttrs (map (l: lib.nameValuePair l true) enabledLangs);
        in
        {
          home.packages = [
            (wlib.evalPackage [
              { inherit pkgs; }
              (
                {
                  pkgs,
                  wlib,
                  config,
                  ...
                }:
                {
                  imports = [ wlib.wrapperModules.neovim ];
                  package = nvimPkg;
                  inherit runtimePkgs;
                  specs = import ./_plugins.nix {
                    inherit pkgs lzextrasLatest;
                    # postPatch: upstream typo makes multi-rule merge unreachable for
                    # sameLine sources (pyright/ruff) — appends a 2nd ignore comment
                    # instead of merging. --replace-fail breaks the build when upstream
                    # fixes it, signalling the patch can be dropped.
                    rulebookPlugin =
                      (config.nvim-lib.mkPlugin "nvim-rulebook" inputs.nvim-rulebook).overrideAttrs
                        (old: {
                          postPatch = ''
                            substituteInPlace lua/rulebook/diagnostic-actions.lua \
                              --replace-fail 'location == "location"' 'location == "sameLine"'
                          '';
                        });
                  };
                  info = {
                    nixdExtras.nixpkgs = "import ${pkgs.path} {}";
                    inherit categories;
                    formatters = {
                      fast = fastFormatters;
                      slow = slowFormatters;
                    };
                    inherit linters;
                  };
                  settings = {
                    aliases = [ "vim" ];
                    config_directory = ./.;
                    block_normal_config = true;
                  };
                  hosts = {
                    python3.nvim-host.enable = true;
                    node.nvim-host.enable = true;
                  };
                }
              )
            ])
          ];
        };
    };
in
{
  flake-file.inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  flake-file.inputs.lzextras.url = "github:BirdeeHub/lzextras";
  flake-file.inputs.nvim-rulebook = {
    url = "github:chrisgrieser/nvim-rulebook";
    flake = false;
  };

  den.aspects.nvim = {
    includes = [ nvimPerUser ];
  };
}
