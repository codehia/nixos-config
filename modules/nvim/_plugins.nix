{ pkgs, lzextrasLatest }:
with pkgs.vimPlugins;
{
  # Startup (lazy = false)
  lze = {
    data = lze;
    lazy = false;
  };
  lzextras = {
    data = lzextrasLatest;
    lazy = false;
  };
  snacks = {
    data = snacks-nvim;
    lazy = false;
  };
  catppuccin = {
    data = catppuccin-nvim;
    lazy = false;
  };
  plenary = {
    data = plenary-nvim;
    lazy = false;
  };

  # General (lazy = true, loaded by lze in lua/)
  mini = {
    data = mini-nvim;
    lazy = true;
  };
  vim-sleuth = {
    data = vim-sleuth;
    lazy = false;
  };
  lspconfig = {
    data = nvim-lspconfig;
    lazy = true;
  };
  blink-cmp = {
    data = blink-cmp;
    lazy = true;
  };
  blink-cmp-cp = {
    data = blink-cmp-copilot;
    lazy = true;
  };
  navic = {
    data = nvim-navic;
    lazy = true;
  };
  treesitter = {
    data = nvim-treesitter.withAllGrammars;
    lazy = true;
  };
  treesitter-to = {
    data = nvim-treesitter-textobjects;
    lazy = true;
  };
  ibl = {
    data = indent-blankline-nvim;
    lazy = true;
  };
  dressing = {
    data = dressing-nvim;
    lazy = true;
  };
  gitsigns = {
    data = gitsigns-nvim;
    lazy = true;
  };
  which-key = {
    data = which-key-nvim;
    lazy = true;
  };
  oil = {
    data = oil-nvim;
    lazy = true;
  };
  telescope = {
    data = telescope-nvim;
    lazy = true;
  };
  telescope-fzf = {
    data = telescope-fzf-native-nvim;
    lazy = true;
  };
  telescope-ui = {
    data = telescope-ui-select-nvim;
    lazy = true;
  };
  nvim-lint = {
    data = nvim-lint;
    lazy = true;
  };
  conform = {
    data = conform-nvim;
    lazy = true;
  };
  dap = {
    data = nvim-dap;
    lazy = true;
  };
  dap-ui = {
    data = nvim-dap-ui;
    lazy = true;
  };
  dap-vtext = {
    data = nvim-dap-virtual-text;
    lazy = true;
  };
  dap-go = {
    data = nvim-dap-go;
    lazy = true;
  };
  nvim-nio = {
    data = nvim-nio;
    lazy = true;
  };
  copilot = {
    data = copilot-lua;
    lazy = true;
  };
  startuptime = {
    data = vim-startuptime;
    lazy = true;
  };
  snippets = {
    data = friendly-snippets;
    lazy = true;
  };
  luasnip = {
    data = luasnip;
    lazy = true;
  };
  lazydev = {
    data = lazydev-nvim;
    lazy = true;
  };

  # New from codehia/neovim
  avante = {
    data = avante-nvim;
    lazy = true;
  };
  render-md = {
    data = render-markdown-nvim;
    lazy = true;
  };
  img-clip = {
    data = img-clip-nvim;
    lazy = true;
  };
  copilot-chat = {
    data = CopilotChat-nvim;
    lazy = true;
  };
  nui = {
    data = nui-nvim;
    lazy = true;
  };
  harpoon2 = {
    data = harpoon2;
    lazy = true;
  };
  noice = {
    data = noice-nvim;
    lazy = true;
  };
  trouble = {
    data = trouble-nvim;
    lazy = true;
  };
  todo-comments = {
    data = todo-comments-nvim;
    lazy = true;
  };
  zen-mode = {
    data = zen-mode-nvim;
    lazy = true;
  };
  twilight = {
    data = twilight-nvim;
    lazy = true;
  };
  octo = {
    data = octo-nvim;
    lazy = true;
  };
  lspsaga = {
    data = lspsaga-nvim;
    lazy = true;
  };
  lspkind = {
    data = lspkind-nvim;
    lazy = true;
  };
  web-devicons = {
    data = nvim-web-devicons;
    lazy = true;
  };
  fzf-lua = {
    data = fzf-lua;
    lazy = true;
  };
  fiendly-snippets = {
    data = friendly-snippets;
    lazy = true;
  };
  hardtime = {
    data = hardtime-nvim;
    lazy = false;
  };
  markview = {
    data = markview-nvim;
    lazy = false;
  };
}
