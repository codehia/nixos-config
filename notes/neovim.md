# Neovim Configuration — Reference

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

## nix-wrapper-modules

Wraps the neovim binary at build time with:
- Plugins baked into packpath (`start/` or `opt/`)
- LSP binaries + tools on `PATH`
- Nix data (`info`) exposed as a Lua module at runtime
- Config directory pre-set (no `~/.config/nvim` loading)

### Key Options

| Option | Our setting | Purpose |
|--------|-------------|---------|
| `package` | `pkgs.unstable.neovim-unwrapped` | Neovim 0.11 from unstable |
| `specs` | from `_plugins.nix` | Plugin declarations |
| `info` | categories, formatters, linters | Nix data → Lua |
| `settings.config_directory` | `./.` (nvim/ dir) | Where init.lua lives |
| `settings.block_normal_config` | `true` | Ignores `~/.config/nvim` |
| `settings.aliases` | `["vim" "nvim"]` | Shell aliases |
| `extraPackages` | from `_lang-defs.nix` | LSPs, formatters, linters on PATH |
| `hosts.python3.nvim-host.enable` | `true` | Python provider |
| `hosts.node.nvim-host.enable` | `true` | Node provider |

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

- `lazy = false` → placed in `start/` → auto-loaded at startup (no lze needed)
- `lazy = true` → placed in `opt/` → must be loaded explicitly (lze handles this)

---

## `_lang-defs.nix` — Per-Language Definitions

```nix
{ pkgs }: {
  general = {             # always included
    packages = with pkgs; [ lazygit ripgrep fd fzf ... ];
    formatters.fast = { sh = ["shfmt"]; markdown = ["markdownlint"]; };
    formatters.slow = {};
    linters = {};
  };
  lua     = { packages = [ lua-language-server stylua ]; formatters.fast = { lua = ["stylua"]; }; };
  nix     = { packages = [ nixd nixfmt-rfc-style ]; formatters.fast = { nix = ["nixfmt"]; }; };
  python  = { packages = [ basedpyright flake8 autopep8 isort ]; ... };
  typescript = { packages = [ typescript-language-server prettier eslint_d ]; ... };
  go      = { packages = [ gopls delve golangci-lint go ]; ... };
  latex   = { packages = [ texlab latexrun biber ]; ... };
}
```

`nvim.nix` consumes this to build `extraPackages` and `info` from the enabled languages.
Adding a new language = add a block here, then add the name to `host.nvimLanguages` or
`user.nvimLanguages` in the host declaration.

### Per-host language config (hosts.nix)

```nix
den.hosts.x86_64-linux.thinkpad = {
  nvimLanguages = [ "lua" "nix" "python" "typescript" "go" "latex" ];
  users.soumya = {
    nvimLanguages = [ "nix" "lua" "python" "typescript" ];
  };
};
```

---

## info → Lua Bridge

```nix
# Nix side (nvim.nix)
info = {
  categories = { lua = true; nix = true; python = true; };
  formatters.fast = { lua = ["stylua"]; nix = ["alejandra"]; };
  linters = {};
  nixdExtras.nixpkgs = "import ${pkgs.path} {}";
};
```

```lua
-- Lua side (init.lua)
local nix = require(vim.g.nix_info_plugin_name)
-- Signature: nix(default, "key1", "key2", ...)
local hasPython = nix(false, "categories", "python")
local formatters = nix({}, "formatters", "fast")
local nixpkgs   = nix("", "nixdExtras", "nixpkgs")
```

Always use the function form — direct indexing is unsafe if the path is missing.

---

## lze — Lazy Loading

lze is a **pure Lua** lazy-loading library. It only handles WHEN to `packadd` a plugin.
nix-wrapper-modules handles WHERE plugins live in the packpath.

```lua
-- init.lua
require('lze').load({
  { "snacks.nvim",
    event = "DeferredUIEnter",
    after = function() require("snacks").setup({...}) end,
  },
  { "nvim-treesitter",
    ft = { "lua", "nix", "python" },
    after = function() require("nvim-treesitter.configs").setup({...}) end,
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

The lze spec name `[1]` must match the **Nix pname** (packpath directory name), NOT the
Nix attrset key or the nixpkgs attribute name:

| Nix attr | Package pname (lze name) | Lua require |
|----------|--------------------------|-------------|
| `snacks-nvim` | `snacks.nvim` | `require('snacks')` |
| `markview-nvim` | `markview.nvim` | `require('markview')` |
| `hardtime-nvim` | `hardtime.nvim` | `require('hardtime')` |
| `nvim-lspconfig` | `nvim-lspconfig` | `require('lspconfig')` |
| `blink-cmp` | `blink-cmp` | `require('blink.cmp')` |

Find it with: `find /nix/store -maxdepth 3 -name "<pattern>*" -type d`
Format: `vimplugin-<PNAME>-<version>` → extract PNAME.

---

## lzextras

Extensions for lze — adds extra load functions and handlers.

```lua
-- init.lua
require('lze').register_handlers(require('lzextras').lsp)
require('lze').register_handlers(require('lzextras').merge)
```

| Function | Purpose |
|----------|---------|
| `lzextras.with_after` | Loads plugin + its `/after` dir |
| `lzextras.multi` | Loads multiple plugins |
| `lzextras.key2spec` | Convert keymap.set syntax to lze key spec |

**Note:** The lzextras LSP handler is registered in our config but **not used for actual
LSP config**. We use the native Neovim 0.11 API directly (see below).

---

## LSP Setup — Native Neovim 0.11 API

File: `lua/config/lsp.lua`

```lua
-- Global on_attach (all servers)
vim.lsp.config('*', { on_attach = M.on_attach })

-- Per-server config (guarded by category check)
if nix_has_feature('lua') then
  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.git' },
    settings = { Lua = { ... } },
  })
end

-- nixd uses info from Nix
if nix_has_feature('nix') then
  vim.lsp.config('nixd', {
    cmd = { 'nixd' },
    filetypes = { 'nix' },
    settings = { nixd = { nixpkgs = { expr = nix_info("", "nixdExtras", "nixpkgs") } } },
  })
end

-- Enable all configured servers at once
vim.lsp.enable({ 'lua_ls', 'nixd', 'basedpyright', 'ts_ls', 'gopls', 'texlab' })
```

`nix_has_feature('lang')` returns false when the language is disabled → we skip
`vim.lsp.config` → we don't `enable` the server → no "executable not found" errors.

---

## blink-cmp — Known Gotchas

### Snippet expansion appends instead of replacing (`fun → funfunc`)

Do **not** use `snippets.preset = 'luasnip'`. Use explicit expand/active/jump functions
so blink-cmp controls prefix deletion before expanding:

```lua
snippets = {
  expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
  active = function(filter)
    if filter and filter.direction then return require('luasnip').jumpable(filter.direction) end
    return require('luasnip').in_snippet()
  end,
  jump = function(direction) require('luasnip').jump(direction) end,
},
```

### Tab jumps cursor instead of inserting tab

Do **not** use `'snippet_forward'` in keymaps — it fires even after a snippet session
ends. Use `luasnip.locally_jumpable()` in a custom function instead.

### Go filetype: uses tabs

`expandtab = true` globally, overridden per-buffer in `autocmds.lua` for `go`/`gomod`
filetypes (`tabstop = 4`, `shiftwidth = 4`, `expandtab = false`).

---

## Adding a New Plugin — End to End

1. **`_plugins.nix`**: add `my-plugin = { data = pkgs.vimPlugins.my-plugin-nvim; lazy = true; };`
2. **Find lze name**: `find /nix/store -maxdepth 3 -name "my-plugin*" -type d` → extract pname
3. **`lua/plugins/something.lua`**: add `{ "my-plugin.nvim", ft = { "rust" }, after = function() require("my-plugin").setup({}) end }`
4. **If LSP**: add to `_lang-defs.nix`, guard with `nix_has_feature` in `lsp.lua`, add to `vim.lsp.enable` list

---

## Key Files

| File | Purpose |
|------|---------|
| `nvim.nix` | perUser wrapper — builds the derivation, sets info |
| `_plugins.nix` | All plugin declarations (Nix side) |
| `_lang-defs.nix` | Per-language packages/formatters/linters |
| `lua/` | Runtime Lua config (standard Neovim layout) |
| `lua/config/lsp.lua` | Native 0.11 LSP setup |
| `lua/plugins/` | lze plugin specs (Lua side) |

---

## References

- [BirdeeHub/nix-wrapper-modules](https://birdeehub.github.io/nix-wrapper-modules/)
- [BirdeeHub/lze](https://github.com/BirdeeHub/lze)
- [BirdeeHub/lzextras](https://github.com/BirdeeHub/lzextras)
- `.claude/research/nvim-wrapper.md` — full API reference (local)
- `.claude/research/nvim-wrapper-charts.md` — visual diagrams (local)
