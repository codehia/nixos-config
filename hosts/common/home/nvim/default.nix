{ inputs, ... }:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [ inputs.nixCats.homeModule ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      enable = true;
      # nixpkgs_version = inputs.nixpkgs;
      # this will add the overlays from ./overlays and also,
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      addOverlays = # (import ./overlays inputs) ++
        [ (utils.standardPluginOverlay inputs) ];
      # see the packageDefinitions below.
      # This says which of those to install.
      packageNames = [ "myHomeModuleNvim" ];

      luaPath = ./.;

      # the .replace vs .merge options are for modules based on existing configurations,
      # they refer to how multiple categoryDefinitions get merged together by the module.
      # for useage of this section, refer to :h nixCats.flake.outputs.categories
      categoryDefinitions.replace = (
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              # Git tools
              lazygit
              git

              # Search and navigation
              ripgrep
              fd
              fzf

              # Fun tools for starter
              fortune
              cowsay

              # Development tools
              universal-ctags
              gnumake
              gcc
            ];
            lua = with pkgs; [
              lua-language-server
              stylua
            ];
            nix = with pkgs; [
              nixd
              alejandra
            ];
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
              # LSP
              basedpyright
              # Linting (prefer flake8 if available locally, fallback to ruff)
              python3Packages.flake8
              ruff
              # Formatting (prefer autopep8 if available locally, fallback to black)
              python3Packages.autopep8
              black
              isort
            ];
            typescript = with pkgs; [
              # LSP
              typescript-language-server
              # Formatting
              nodePackages.prettier
              # Linting
              eslint_d
            ];
            latex = with pkgs; [
              texlab
            ];
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            general = with pkgs.vimPlugins; [
              # Core plugins needed at startup
              lze
              lzextras
              snacks-nvim
            ];
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          optionalPlugins = {
            go = with pkgs.vimPlugins; [ nvim-dap-go ];
            lua = with pkgs.vimPlugins; [ lazydev-nvim ];
            latex = with pkgs.vimPlugins; [ vimtex ];
            general = with pkgs.vimPlugins; [
              # Core functionality
              mini-nvim
              vim-sleuth

              # LSP and completion
              nvim-lspconfig
              blink-cmp
              nvim-navic

              # Syntax and treesitter
              nvim-treesitter.withAllGrammars
              nvim-treesitter-textobjects

              # UI and statusline (lualine disabled in favor of mini.statusline)
              # lualine-nvim
              # lualine-lsp-progress
              catppuccin-nvim
              indent-blankline-nvim
              dressing-nvim
              nvim-ufo

              # Git integration
              gitsigns-nvim

              # Navigation and editing
              which-key-nvim
              oil-nvim
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim

              # Formatting and linting
              nvim-lint
              conform-nvim

              # Debugging
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text

              # GitHub Copilot
              copilot-lua
              blink-cmp-copilot

              # Utilities
              vim-startuptime

              friendly-snippets
              luasnip
            ];
          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = {
            general = with pkgs; [ ];
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            # test = {
            #   CATTESTVAR = "It worked!";
            # };
          };

          # categories of the function you would have passed to withPackages
          python3.libraries = {
            # test = [ (_:[]) ];
          };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = {
            # test = [
            #   '' --set CATTESTVAR2 "It worked again!"''
            # ];
          };
        }
      );

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions.replace = {
        # These are the names of your packages
        # you can include as many as you wish.
        myHomeModuleNvim =
          { pkgs, name, ... }:
          {
            # they contain a settings set defined above
            # see :help nixCats.flake.outputs.settings
            settings = {
              suffix-path = true;
              suffix-LD = true;
              wrapRc = true;
              # unwrappedCfgPath = ./.;
              # IMPORTANT:
              # your alias may not conflict with your other packages.
              aliases = [
                "vim"
                "nvim"
                "homeVim"
              ];
              # Use neovim 0.11.4 from nixpkgs-unstable
              neovim-unwrapped = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.neovim-unwrapped;
              hosts.python3.enable = true;
              hosts.node.enable = true;
            };
            # and a set of categories that you want
            # (and other information to pass to lua)
            # and a set of categories that you want
            categories = {
              general = true;
              lua = true;
              nix = true;
              python = true;
              typescript = true;
              go = false;
              latex = true;
            };
            # anything else to pass and grab in lua with `nixCats.extra`
            extra = {
              nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            };
          };
      };
    };
  };
}
