{ inputs, lib, ... }:

let luaInlineFunction = luaFunction: lib.generators.mkLuaInline luaFunction;
in {
  imports = [ inputs.nvf.homeManagerModules.default ];
  # home.packages = with pkgs; [ neovim ];
  programs.nvf = {
    enable = true;
    settings.vim = {
      mini = {
        animate.enable = true;
        ai = {
          enable = true;
          setupOpts = { n_lines = 500; };
        };
        # TODO: Check how to enable treesitter config
        surround = { enable = true; };
        starter = {
          enable = true;
          setupOpts = {
            header = luaInlineFunction ''
              function()
                local handle = assert(io.popen('fortune -s | cowsay', 'r'))
                local output = handle:read '*all'
                handle:close()
                return output
              end'';
            items = luaInlineFunction ''
              {
                require("mini.starter").sections.recent_files(5, true, false),
                require("mini.starter").sections.builtin_actions(),
              }'';
            content_hooks = luaInlineFunction ''
              {
                require("mini.starter").gen_hook.adding_bullet(),
                require("mini.starter").gen_hook.aligning('center', 'center'),
                require("mini.starter").gen_hook.indexing('all', { 'Builtin actions' }),
                require("mini.starter").gen_hook.padding(3, 2),
              }'';
            footer = "";
          };
        };
        statusline = {
          enable = true;
          #          setupOpts = {
          #            active = luaInlineFunction ''
          #           function()
          #       local mode, mode_hl = statusline.section_mode { trunc_width = 20000 }
          #       local git = statusline.section_git { trunc_width = 40 }
          #       local filename = statusline.section_filename { trunc_width = 20000 }
          #       local fileinfo = statusline.section_fileinfo { trunc_width = 20000 }
          #       local location = statusline.section_location()
          #       -- Check why the LSP is showing ++ and add to fileinfo
          #       -- local lsp = statusline.section_lsp { trunc_width = 20, icon = '󰿘 ' }
          #       return statusline.combine_groups {
          # 	{ hl = mode_hl, strings = { mode } },
          # 	{ hl = 'MiniStatuslineDevinfo', strings = { git } },
          # 	'%<', -- Mark general truncate point
          # 	{ hl = 'MiniStatuslineFilename', strings = { filename } },
          # 	'%=', -- End left alignment
          # 	{ hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
          # 	{ hl = mode_hl, strings = { location } },
          #       }
          #     end
          #     statusline.section_location = function()
          #       return '%2l:%-2v'
          #     end
          # end'';
          #          };
        };

      };
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
        list = true;
        # listchars = {
        #   eol = "↲"; # End of line
        #   tab = "▏·"; # Tab character (Arrow followed by a dot)
        #   trail = "·"; # Trailing spaces
        #   extends = "⟩"; # Character when text extends beyond the window
        #   precedes = "⟨"; #Character when text precedes the window
        #   nbsp = "␣"; # Non-breaking space
        # };
        tabstop = 4;
        shiftwidth = 2;
        wrap = false;
        inccommand = "split";
        cursorline = true;
        hlsearch = true;
        smoothscroll = true;
        # fillchars = {
        #   foldopen = "";
        #   foldclose = "";
        #   fold = " ";
        #   foldsep = " ";
        #   diff = "╱";
        #   eob = " ";
        # };
      };

      lsp.enable = true;
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      # lineNumberMode = "relNumber";
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
      # spellcheck = {
      #   enable = false;
      #   languages = [ "en" ];
      #   programmingWordlist.enable = true;
      # };

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
        # enableFormat = true;
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

        # Nim LSP is broken on Darwin and therefore
        # should be disabled by default. Users may still enable
        # `vim.languages.vim` to enable it, this does not restrict
        # that.
        # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
        nim.enable = false;
      };

      # languages = {
      #   enableFormat = true;
      #   enableTreesitter = true;
      #   enableExtraDiagnostics = true;
      #   nix.enable = true;
      #   clang.enable = true;
      #   zig.enable = true;
      #   python.enable = true;
      #   markdown.enable = true;
      #   ts = {
      #     enable = true;
      #     lsp.enable = true;
      #     format.type = "prettierd";
      #     extensions.ts-error-translator.enable = true;
      #   };
      #   html.enable = true;
      #   lua.enable = true;
      #   css = {
      #     enable = true;
      #     format.type = "prettierd";
      #   };
      #   typst.enable = true;
      #   rust = {
      #     enable = true;
      #     crates.enable = true;
      #   };
      # };
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
      # statusline.lualine = {
      #   enable = true;
      #   # theme = "base16";
      # };

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
      # tabline.nvimBufferline.enable = true;
      treesitter.context.enable = false;
      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };
      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false;
      };
      # projects.project-nvim.enable = true;
      # dashboard.dashboard-nvim.enable = true;
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
        # borders.enable = true;
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
