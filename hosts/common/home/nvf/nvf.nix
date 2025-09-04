{ inputs, ... }: {
  imports = [ inputs.nvf.homeManagerModules.default ];
  programs.nvf = {
    enable = true;
    settings.vim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      options = {
        number = true;
        relativenumber = true;
        mouse = "";
        showmode = false;
        breakindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes";
        updatetime = 250;
        timeoutlen = 300;
        splitright = true;
        splitbelow = true;
        listchars = "eol:↲,tab:▏·,trail:·,extends:⟩,precedes:⟨,nbsp:␣";
        list = true;
        tabstop = 4;
        shiftwidth = 2;
        wrap = false;
        inccommand = "split";
        cursorline = true;
        hlsearch = true;
        smoothscroll = true;
        fillchars = "foldopen:,foldclose:,fold:.,foldsep: ,diff:╱,eob: ";
        foldcolumn = "0";
        foldmethod = "expr";
        foldexpr = "v:lua.vim.treesitter.foldexpr()";
        foldtext = "";
        foldnestmax = 3;
        foldlevel = 99;
        foldlevelstart = 99;
      };

      lsp.enable = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      enableLuaLoader = true;
      preventJunkFiles = true;
      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers = {
          wl-copy.enable = true;
          xsel.enable = true;
        };
      };
      diagnostics = {
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            markdown = [ "markdownlint" ];
            python = [ "flake8" ];
          };
        };
      };
      formatter = {
        conform-nvim = {
          enable = true;
          setupOpts = {
            formatters_by_ft = { python = [ "isort" "autopep8" ]; };
          };
        };
      };

      lsp = {
        formatOnSave = true;
        lspkind.enable = true;
        lightbulb.enable = true;
        lspsaga.enable = true;
        trouble.enable = true;
        lspSignature.enable = false;
        otter-nvim.enable =
          false; # lsp features and a code completion source for code embedded in other documents
        nvim-docs-view.enable = true;
      };

      languages = {
        enableFormat = false;
        enableTreesitter = true;
        enableExtraDiagnostics = true;
        nix.enable = true;
        markdown.enable = true;
        bash.enable = true;
        clang.enable = true;
        html.enable = true;
        sql.enable = true;
        go.enable = true;
        lua.enable = true;
        python.enable = true;
        tailwind.enable = true;
        css = {
          enable = true;
          lsp.enable = true;
          format.type = "prettierd";
        };
        ts = {
          enable = true;
          lsp.enable = true;
          format.type = "prettierd";
          extensions.ts-error-translator.enable = true;
        };
        rust = {
          enable = true;
          crates.enable = true;
        };
        # Language modules that are not as common.
        java.enable = false;
        kotlin.enable = false;
        zig.enable = false;
        assembly.enable = false;
        typst.enable = false;
        astro.enable = false;
        nu.enable = false;
        csharp.enable = false;
        julia.enable = false;
        vala.enable = false;
        scala.enable = false;
        r.enable = false;
        gleam.enable = false;
        dart.enable = false;
        ocaml.enable = false;
        elixir.enable = false;
        haskell.enable = false;
        ruby.enable = false;
        fsharp.enable = false;
        svelte.enable = false;
        nim.enable = false;
      };

      visuals = {
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
        rainbow-delimiters.enable = false;
      };
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };
      autopairs.nvim-autopairs = {
        enable = true;
        # TODO: Check if the () after selecting a function doesn't show and update setupOpts accordingly
        # setupOpts = {};
      };
      # TODO: Add better quick fix: nvim-bqf
      autocomplete = {
        blink-cmp = {
          enable = true;
          friendly-snippets.enable = true;
          mappings = {
            confirm = "<C-y>";
            next = "<C-n>";
            previous = "<C-p>";
            close = "<C-e>";
          };
        };
      };
      snippets.luasnip.enable = true;
      # treesitter = {
      #   context.enable = false;
      #   textObjects = {
      #     enable = true;
      #     setupOpts = {
      #
      #     };
      #
      #   };
      # };
      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };
      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false;
      };
      notify = {
        nvim-notify.enable = false;
        # nvim-notify.setupOpts.background_colour = "#${config.lib.stylix.colors.base01}";
      };
      utility = {
        preview.markdownPreview.enable = true;
        ccc.enable = false;
        vim-wakatime.enable = false;
        icon-picker.enable = true;
        # surround.enable = true;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
          precognition.enable = false;
        };
        images = { image-nvim.enable = false; };
      };
      ui = {
        borders.enable = true;
        # noice.enable = true;
        # colorizer.enable = true;
        # illuminate.enable = true;
        # # breadcrumbs = {
        # #   enable = true;
        # #   navbuddy.enable = false;
        # #   lualine.winbar.enable = false;
        # # };
        # smartcolumn = { enable = true; };
        # fastaction.enable = true;
      };

      # session = {
      #   nvim-session-manager.enable = false;
      # };
      comments = { comment-nvim.enable = true; };
    };
  };
}
