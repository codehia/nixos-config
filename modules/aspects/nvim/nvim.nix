{
  inputs,
  lib,
  den,
  ...
}:
let
  wlib = inputs.wrappers.lib;
in
{
  flake-file.inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  flake-file.inputs.lzextras.url = "github:BirdeeHub/lzextras";

  den.aspects.nvim = {
    # perUser so homeManager forwarding reaches ctx.hm-user, and host.nvimLanguages is accessible.
    includes = [
      (den.lib.perUser (
        { host, ... }:
        let
          languages =
            host.nvimLanguages or [
              "lua"
              "nix"
            ];
        in
        {
          homeManager =
            { pkgs, ... }:
            let
              nvimPkg =
                inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;

              lzextrasLatest = inputs.lzextras.packages.${pkgs.stdenv.hostPlatform.system}.lzextras-vimPlugin;

              langDefs = import ./_lang-defs.nix { inherit pkgs; };
              enabledLangs = [ "general" ] ++ languages;

              # Collect packages from all enabled languages
              extraPackages = lib.concatMap (l: langDefs.${l}.packages) enabledLangs;

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
                    { pkgs, wlib, ... }:
                    {
                      imports = [ wlib.wrapperModules.neovim ];
                      package = nvimPkg;
                      inherit extraPackages;
                      specs = import ./_plugins.nix { inherit pkgs lzextrasLatest; };
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
        }
      ))
    ];
  };
}
