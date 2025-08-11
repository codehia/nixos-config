{inputs, ...}: {
  imports = [inputs.nvf.homeManagerModules.default];

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
        undofiles = true;
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes";
        updatetime = 250;
        timoutlen = 300;
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
      lineNumberMode = "relNumber";
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

      maps = {
        normal = {
          "<leader>e" = {
            action = "<CMD>Neotree toggle<CR>";
            silent = false;
          };
        };
      };

      diagnostics = {
        enable = true;
        config = {
          virtual_lines.enable = true;
          underline = true;
        };
      };

      keymaps = [
        {
          key = "jk";
          mode = ["i"];
          action = "<ESC>";
          desc = "Exit insert mode";
        }
        {
          key = "<leader>nh";
          mode = ["n"];
          action = ":nohl<CR>";
          desc = "Clear search highlights";
        }
        {
          key = "<leader>ff";
          mode = ["n"];
          action = "<cmd>Telescope find_files<cr>";
          desc = "Search files by name";
        }
        {
          key = "<leader>lg";
          mode = ["n"];
          action = "<cmd>Telescope live_grep<cr>";
          desc = "Search files by contents";
        }
        {
          key = "<leader>fe";
          mode = ["n"];
          action = "<cmd>Neotree toggle<cr>";
          desc = "File browser toggle";
        }
        {
          key = "<C-h>";
          mode = ["i"];
          action = "<Left>";
          desc = "Move left in insert mode";
        }
        {
          key = "<C-j>";
          mode = ["i"];
          action = "<Down>";
          desc = "Move down in insert mode";
        }
        {
          key = "<C-k>";
          mode = ["i"];
          action = "<Up>";
          desc = "Move up in insert mode";
        }
        {
          key = "<C-l>";
          mode = ["i"];
          action = "<Right>";
          desc = "Move right in insert mode";
        }
      ];

      telescope.enable = true;

      spellcheck = {
        enable = true;
        languages = ["en"];
        programmingWordlist.enable = false;
      };

      lsp = {
        formatOnSave = true;
        lspkind.enable = true;
        lightbulb.enable = true;
        lspsaga.enable = true;
        trouble.enable = true;
        lspSignature.enable = false;
        otter-nvim.enable = false; # lsp features and a code completion source for code embedded in other documents
        nvim-docs-view.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # Languages that will be supported in default and maximal configurations.
        nix.enable = true;
        markdown.enable = true;

        # Languages that are enabled in the maximal configuration.
        bash.enable = true;
        clang.enable = true;
        css = {
          enable = true;
          lsp.enable = true;
          format.type = "prettierd";
        };
        html.enable = true;
        sql.enable = true;
        java.enable = false;
        kotlin.enable = false;
        ts = {
          enable = true;
          lsp.enable = true;
          format.type = "prettierd";
          extensions.ts-error-translator.enable = true;
        };
        go.enable = true;
        lua.enable = true;
        zig.enable = false;
        python.enable = true;
        typst.enable = false;
        rust = {
          enable = false;
          crates.enable = false;
        };
        # Language modules that are not as common.
        assembly.enable = false;
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

        tailwind.enable = true;
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
        rainbow-delimiters.enable = true;
      };
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };
      statusline.lualine = {
        enable = true;
        theme = "base16";
      };

      autopairs.nvim-autopairs.enable = true;
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
      tabline.nvimBufferline.enable = true;
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
      projects.project-nvim.enable = true;
      dashboard.dashboard-nvim.enable = true;
      filetree.neo-tree.enable = true;
      notify = {
        nvim-notify.enable = true;
        # nvim-notify.setupOpts.background_colour = "#${config.lib.stylix.colors.base01}";
      };
      utility = {
        preview.markdownPreview.enable = true;
        ccc.enable = false;
        vim-wakatime.enable = false;
        icon-picker.enable = true;
        surround.enable = true;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
          precognition.enable = false;
        };
        images = {
          image-nvim.enable = false;
        };
      };
      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        breadcrumbs = {
          enable = false;
          navbuddy.enable = false;
        };
        smartcolumn = {
          enable = true;
        };
        fastaction.enable = true;
      };

      session = {
        nvim-session-manager.enable = false;
      };
      comments = {
        comment-nvim.enable = true;
      };
    };
  };
}
# nvf = {
#   enable = true;
#   settings = {
#     vim = {
#       preventJunkFiles = false;
#       options = {
#         mouse = "";
#         winborder = "rounded";
#         timeoutlen = 600;
#         smartcase = true;
#         relativenumber = true;
#         number = true;
#         wrap = false;
#         expandtab = true;
#         # scrolloff
#         # exrc
#         # linebreak
#       };
#       globals = {
#         mapleader = " ";
#         maplocalleader = " ";
#       };
#       treesitter = {
#         enable = true;
#         autotagHtml = true;
#         incrementalSelection.enable = false;
#         addDefaultGrammars = false; # true maybe?
#         indent.disable = [ "nix" ];
#       };
#
#       viAlias = true;
#       lsp = {
#         enable = true;
#         lspkind.enable = true;
#         lspsaga.enable = true;
#       };
#       enableLuaLoader = true;
#       autocomplete = {
#         nvim-cmp = {
#           enable = true;
#           mappings = {
#             confirm = "<C-y>";
#             next = "<C-n>";
#             previous = "<C-p>";
#             close = "<C-e>";
#
#           };
#         };
#       };
#       languages = {
#         python = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#           format.enable = true;
#         };
#         nix = {
#           enable = true;
#           treesitter.enable = true;
#           lsp = {
#             enable = true;
#             server = "nil";
#           };
#           format = {
#             enable = true;
#             package = pkgs.nixfmt-rfc-style;
#             type = "nixfmt";
#           };
#         };
#         lua = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         ts = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         go = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         rust = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#       };
#     };
#   };
# };
# nvf = {
#   enable = true;
#   settings = {
#     vim = {
#       preventJunkFiles = false;
#       options = {
#         mouse = "";
#         winborder = "rounded";
#         timeoutlen = 600;
#         smartcase = true;
#         relativenumber = true;
#         number = true;
#         wrap = false;
#         expandtab = true;
#         # scrolloff
#         # exrc
#         # linebreak
#       };
#       globals = {
#         mapleader = " ";
#         maplocalleader = " ";
#       };
#       treesitter = {
#         enable = true;
#         autotagHtml = true;
#         incrementalSelection.enable = false;
#         addDefaultGrammars = false; # true maybe?
#         indent.disable = [ "nix" ];
#       };
#
#       viAlias = true;
#       lsp = {
#         enable = true;
#         lspkind.enable = true;
#         lspsaga.enable = true;
#       };
#       enableLuaLoader = true;
#       autocomplete = {
#         nvim-cmp = {
#           enable = true;
#           mappings = {
#             confirm = "<C-y>";
#             next = "<C-n>";
#             previous = "<C-p>";
#             close = "<C-e>";
#
#           };
#         };
#       };
#       languages = {
#         python = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#           format.enable = true;
#         };
#         nix = {
#enable = true;
#           treesitter.enable = true;
#           lsp = {
#             enable = true;
#             server = "nil";
#           };
#           format = {
#             enable = true;
#             package = pkgs.nixfmt-rfc-style;
#             type = "nixfmt";
#           };
#         };
#         lua = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         ts = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         go = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#         rust = {
#           enable = true;
#           lsp.enable = true;
#           treesitter.enable = true;
#         };
#       };
#     };
#   };
# };

