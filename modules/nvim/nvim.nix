{inputs, ...}: let
  utils = inputs.nixCats.utils;
in {
  flake-file.inputs.nixCats = {url = "github:BirdeeHub/nixCats-nvim";};

  den.aspects.nvim = {
    homeManager = {pkgs, ...}: {
      imports = [inputs.nixCats.homeModule];
      nixCats = {
        enable = true;
        addOverlays = [(utils.standardPluginOverlay inputs)];
        packageNames = ["myHomeModuleNvim"];

        luaPath = ./.;

        categoryDefinitions.replace = {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        } @ packageDef: {
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              lazygit
              git
              ripgrep
              fd
              fzf
              fortune
              cowsay
              universal-ctags
              gnumake
              gcc
            ];
            lua = with pkgs; [lua-language-server stylua];
            nix = with pkgs; [nixd alejandra];
            go = with pkgs; [
              gopls
              delve
              golint
              golangci-lint
              gotools
              go-tools
              go
            ];
            python = with pkgs; [
              basedpyright
              python3Packages.flake8
              ruff
              python3Packages.autopep8
              black
              isort
            ];
            typescript = with pkgs; [
              typescript-language-server
              nodePackages.prettier
              eslint_d
            ];
          };

          startupPlugins = {
            general = with pkgs.vimPlugins; [lze lzextras snacks-nvim];
          };

          optionalPlugins = {
            go = with pkgs.vimPlugins; [nvim-dap-go];
            lua = with pkgs.vimPlugins; [lazydev-nvim];
            general = with pkgs.vimPlugins; [
              mini-nvim
              vim-sleuth
              nvim-lspconfig
              blink-cmp
              nvim-navic
              nvim-treesitter.withAllGrammars
              nvim-treesitter-textobjects
              catppuccin-nvim
              indent-blankline-nvim
              dressing-nvim
              nvim-ufo
              gitsigns-nvim
              which-key-nvim
              oil-nvim
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              nvim-lint
              conform-nvim
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              copilot-lua
              blink-cmp-copilot
              vim-startuptime
              friendly-snippets
              luasnip
            ];
          };

          sharedLibraries = {general = with pkgs; [];};

          environmentVariables = {};

          python3.libraries = {};

          extraWrapperArgs = {};
        };

        packageDefinitions.replace = {
          myHomeModuleNvim = {
            pkgs,
            name,
            ...
          }: {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              aliases = ["vim" "nvim" "homeVim"];
              neovim-unwrapped =
                inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;
              hosts.python3.enable = true;
              hosts.node.enable = true;
            };
            categories = {
              general = true;
              lua = true;
              nix = true;
              python = true;
              typescript = true;
              go = false;
            };
            extra = {nixdExtras.nixpkgs = "import ${pkgs.path} {}";};
          };
        };
      };
    };
  };
}
