# Neovim — Architecture Reference

> Stack: nix-wrapper-modules + lze + lzextras + native Neovim 0.11 LSP API
> Config: `modules/aspects/nvim/`

---

## Architecture Overview

```
Nix side                              Lua side
─────────────────────────────         ─────────────────────────────────
nvim.nix (perUser wrapper)            nvim starts
  └─ wlib.evalPackage                   → init.lua loaded
       └─ wlib.wrapperModules.neovim        → sets up nix_info() helpers
            ├─ package (nvim-unwrapped)      → registers lzextras handlers
            ├─ specs (_plugins.nix)          → M.setup() in lua/config/lsp.lua
            │    lazy=false → start/           → vim.lsp.config(*) on_attach
            │    lazy=true  → opt/             → vim.lsp.config(server, {...})
            ├─ info (categories, formatters)   → vim.lsp.enable([...])
            ├─ settings.config_directory       → require('lze').load(specs)
            ├─ settings.block_normal_config        → handlers watch triggers
            └─ extraPackages (LSPs, tools)         → trigger fires → packadd()
                 from _lang-defs.nix                → after() runs setup
```

---

## nix-wrapper-modules Key Options

| Option | Our setting | Purpose |
|--------|-------------|---------|
| `package` | `pkgs.unstable.neovim-unwrapped` | Neovim 0.11 from unstable |
| `specs` | from `_plugins.nix` | Plugin declarations |
| `info` | categories, formatters, linters | Nix data → Lua |
| `settings.config_directory` | `./.` (nvim/ dir) | Where init.lua lives |
| `settings.block_normal_config` | `true` | Ignores `~/.config/nvim` |
| `settings.aliases` | `["vim" "nvim"]` | Shell aliases |
| `extraPackages` | from `_lang-defs.nix` | LSPs, formatters, linters on PATH |

---

## `_plugins.nix` — Plugin Declarations

```nix
# Three forms:
specs.gitsigns = pkgs.vimPlugins.gitsigns-nvim;       # bare package

specs.treesj = {
  data = pkgs.vimPlugins.treesj;
  lazy = true;
};

specs.lsp-group = [                                     # list of specs
  { data = pkgs.vimPlugins.nvim-lspconfig; lazy = true; }
];
```

- `lazy = false` → `start/` → auto-loaded at startup
- `lazy = true` → `opt/` → loaded on demand by lze

---

## `_lang-defs.nix` — Per-Language Definitions

```nix
{ pkgs }: {
  general = {             # always included
    packages = with pkgs; [ lazygit ripgrep fd fzf ... ];
    formatters.fast = { sh = ["shfmt"]; markdown = ["markdownlint"]; };
  };
  lua     = { packages = [ lua-language-server stylua ]; formatters.fast = { lua = ["stylua"]; }; };
  nix     = { packages = [ nixd alejandra ]; formatters.fast = { nix = ["alejandra"]; }; };
  python  = { packages = [ basedpyright flake8 autopep8 isort ]; ... };
  typescript = { packages = [ typescript-language-server prettier eslint_d ]; ... };
  go      = { packages = [ gopls delve golangci-lint go ]; ... };
  latex   = { packages = [ texlab latexrun biber ]; ... };
}
```

Adding a new language = add a block here + add the name to `host.nvimLanguages`.

---

## info → Lua Bridge

```nix
# Nix side (nvim.nix)
info = {
  categories = { lua = true; nix = true; };
  formatters.fast = { lua = ["stylua"]; nix = ["alejandra"]; };
  nixdExtras.nixpkgs = "import ${pkgs.path} {}";
};
```

```lua
-- Lua side
local nix = require(vim.g.nix_info_plugin_name)
-- Signature: nix(default, "key1", "key2", ...)
local hasPython = nix(false, "categories", "python")
local formatters = nix({}, "formatters", "fast")
```

Always use the function form — direct indexing is unsafe if the path is missing.

---

## lze — Lazy Loading

```lua
require('lze').load({
  { "snacks.nvim",
    event = "DeferredUIEnter",
    after = function() require("snacks").setup({...}) end,
  },
})
```

### Full Spec Fields

| Field | Purpose |
|-------|---------|
| `[1]` | Plugin directory name in packpath (must match pname) |
| `enabled` | boolean or function → skip if false |
| `event` | autocmd event trigger |
| `ft` | filetype trigger |
| `cmd` | user command trigger |
| `keys` | keymap trigger |
| `before` | runs before this plugin loads |
| `after` | runs after this plugin loads |
| `priority` | startup order (higher = earlier, default 50) |
| `dep_of` | load before this other plugin |
| `on_plugin` | load after this other plugin is loaded |

### Plugin Name Gotcha

The lze spec name `[1]` must match the **Nix pname** (packpath directory name):

| Nix attr | Package pname (lze name) | Lua require |
|----------|--------------------------|-------------|
| `snacks-nvim` | `snacks.nvim` | `require('snacks')` |
| `markview-nvim` | `markview.nvim` | `require('markview')` |
| `hardtime-nvim` | `hardtime.nvim` | `require('hardtime')` |
| `nvim-lspconfig` | `nvim-lspconfig` | `require('lspconfig')` |
| `blink-cmp` | `blink-cmp` | `require('blink.cmp')` |

Find it with: `find /nix/store -maxdepth 3 -name "<pattern>*" -type d`

---

## LSP Setup — Native Neovim 0.11 API

```lua
-- Global on_attach (all servers)
vim.lsp.config('*', { on_attach = M.on_attach })

-- Per-server config (guarded by category check)
if nix_has_feature('lua') then
  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.git' },
  })
end

-- Enable all configured servers at once
vim.lsp.enable({ 'lua_ls', 'nixd', 'basedpyright', 'ts_ls', 'gopls', 'texlab' })
```

---

## Key Files

| File | Purpose |
|------|---------|
| `nvim.nix` | perUser wrapper — builds the derivation, sets info |
| `_plugins.nix` | All plugin declarations (Nix side) |
| `_lang-defs.nix` | Per-language packages/formatters/linters |
| `lua/config/lsp.lua` | Native 0.11 LSP setup |
| `lua/plugins/` | lze plugin specs (Lua side) |

---

## References

- [BirdeeHub/nix-wrapper-modules](https://birdeehub.github.io/nix-wrapper-modules/)
- [BirdeeHub/lze](https://github.com/BirdeeHub/lze)
- [BirdeeHub/lzextras](https://github.com/BirdeeHub/lzextras)
- See also: [[Neovim]] (how-to guide for adding plugins/LSPs)
