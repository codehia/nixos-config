# nix-wrapper-modules + lze + lzextras — Visual Reference

> Companion to nvim-wrapper.md

---

## 1. The Big Picture: Nix → Wrapped Binary → Runtime

```
┌─────────────────────────────────────────────────────────────────────┐
│  NIX BUILD TIME                                                     │
│                                                                     │
│  nvim.nix                                                           │
│  ┌───────────────────────────────────────┐                          │
│  │ wlib.evalPackage [                    │                          │
│  │   { inherit pkgs; }                   │                          │
│  │   ({ pkgs, wlib, ... }: {             │                          │
│  │     imports = [wlib.wrapperModules.   │                          │
│  │               neovim];                │                          │
│  │     package  = nvim-unwrapped         │                          │
│  │     specs    = _plugins.nix           │──► build packpath        │
│  │     info     = { categories, fmts }   │──► generate lua info     │
│  │     settings = { aliases, config_dir }│──► wrap binary           │
│  │     extraPkg = LSPs, tools            │──► add to PATH           │
│  │     hosts    = { python3, node }      │──► add to PATH           │
│  │   })                                  │                          │
│  │ ]                                     │                          │
│  └───────────────────────────────────────┘                          │
│                │                                                    │
│                ▼                                                    │
│  ┌─────────────────────────┐                                        │
│  │ Wrapped nvim derivation │                                        │
│  │  bin/vim (alias)        │                                        │
│  │  bin/nvim               │                                        │
│  │  pack/myNeovimPackages/ │                                        │
│  │    start/ ← lazy=false  │                                        │
│  │    opt/   ← lazy=true   │                                        │
│  │  lua/nix-info.lua       │                                        │
│  │  PATH += LSPs, tools    │                                        │
│  └─────────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────────┘
                 │
                 ▼ user runs nvim
┌─────────────────────────────────────────────────────────────────────┐
│  RUNTIME                                                            │
│                                                                     │
│  nvim starts                                                        │
│    │                                                                │
│    ├─ auto-loads start/* plugins (lazy=false ones)                  │
│    │    lze, lzextras, snacks, catppuccin, plenary, hardtime        │
│    │                                                                │
│    └─ loads init.lua (from settings.config_directory)               │
│         │                                                           │
│         ├─ require('lze').register_handlers(require('lzextras').lsp)│
│         │                                                           │
│         └─ require('lze').load({ ...specs... })                     │
│              │                                                      │
│              └─ handlers watch for triggers →                       │
│                   ft / event / keys / cmd / lsp                     │
│                        │                                            │
│                        ▼ trigger fires                              │
│                   vim.cmd.packadd("plugin-name")                    │
│                   → loads from opt/plugin-name/                     │
│                   → after() hook runs (setup calls)                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. `_plugins.nix` Spec → Packpath Location

```
_plugins.nix attrset
┌──────────────────────────────────────────────────────┐
│                                                      │
│  lze        = { data = lze;           lazy = false } │
│  lzextras   = { data = lzextras;      lazy = false } │
│  snacks     = { data = snacks-nvim;   lazy = false } │
│  catppuccin = { data = catppuccin;    lazy = false } │
│                                                      │
│  markview   = { data = markview-nvim; lazy = false } │
│  treesitter = { data = nvim-treesitter; lazy = true }│
│  telescope  = { data = telescope-nvim; lazy = true } │
│  lspconfig  = { data = nvim-lspconfig; lazy = true } │
│  ...                                                 │
└──────────────────────────────────────────────────────┘
         │                              │
    lazy = false                   lazy = true
         │                              │
         ▼                              ▼
pack/myNeovimPackages/          pack/myNeovimPackages/
  start/                          opt/
    lze/           ←──── auto      treesitter/   ←── lze loads
    lzextras/             loaded   telescope/        on trigger
    snacks-nvim/          at       nvim-lspconfig/
    catppuccin-nvim/      startup  ...
    markview-nvim/
```

---

## 3. Plugin Name Mapping (Nix Key vs Lua require)

```
NIX KEY          NIX PACKAGE           PACKPATH DIR          LUA require()
(in _plugins.nix) (vimPlugins.X)       (opt/ or start/)      (in after hooks)

lspconfig   ──►  nvim-lspconfig   ──►  nvim-lspconfig/  ──►  require('lspconfig')
treesitter  ──►  nvim-treesitter  ──►  nvim-treesitter/ ──►  require('nvim-treesitter')
snacks      ──►  snacks-nvim      ──►  snacks-nvim/     ──►  require('snacks')
blink-cmp   ──►  blink-cmp        ──►  blink-cmp/       ──►  require('blink.cmp')
markview    ──►  markview-nvim    ──►  markview-nvim/   ──►  require('markview')  ← NOT 'markview-nvim'
telescope   ──►  telescope-nvim   ──►  telescope-nvim/  ──►  require('telescope')
oil         ──►  oil-nvim         ──►  oil-nvim/        ──►  require('oil')
gitsigns    ──►  gitsigns-nvim    ──►  gitsigns-nvim/   ──►  require('gitsigns')

⚠  The Lua require() name = what's inside the plugin's lua/ directory
   It is NOT necessarily the Nix package name with "-nvim" suffix stripped.
   When in doubt, check the plugin's GitHub repo lua/ directory.
```

---

## 4. lze Spec Fields — At a Glance

```
┌──────────────────────────────────────────────────────────────────────┐
│  LZE PLUGIN SPEC                                                     │
│                                                                      │
│  {                                                                   │
│    "plugin-dir-name",   ← [1]: REQUIRED. Must match opt/ dir name    │
│                                                                      │
│    ── CONDITIONAL ──────────────────────────────────────────────     │
│    enabled = true,      ← bool or function → bool                    │
│                                                                      │
│    ── LIFECYCLE HOOKS ──────────────────────────────────────────     │
│    beforeAll = fn,      ← runs ONCE before any plugin in load()      │
│    before    = fn,      ← runs before THIS plugin loads              │
│    after     = fn,      ← runs after THIS plugin loads ← setup here  │
│    load      = fn,      ← override vim.cmd.packadd per-plugin        │
│                                                                      │
│    ── ORDERING ─────────────────────────────────────────────────     │
│    priority = 50,       ← startup load order (higher = earlier)      │
│                                                                      │
│    ── LAZY TRIGGERS (built-in handlers) ────────────────────────     │
│    event  = "BufEnter",          ← autocmd event                     │
│    ft     = { "lua", "nix" },    ← filetype                          │
│    cmd    = "MyCommand",         ← user command                      │
│    keys   = { "<leader>f" },     ← keymap                            │
│    colorscheme = "catppuccin",   ← colorscheme set                   │
│    dep_of     = "other-plugin",  ← load before other plugin          │
│    on_plugin  = "snacks.nvim",   ← load after other plugin loads     │
│    on_require = "snacks",        ← load when module is required      │
│                                                                      │
│    ── LZEXTRAS HANDLERS ─────────────────────────────────────────    │
│    lsp = function(plugin) ... end,   ← shared LSP setup (function)   │
│    lsp = { filetypes={}, settings={} }, ← per-server config (table)  │
│  }                                                                   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 5. lzextras LSP Handler — Two Spec Shapes

```
require('lze').register_handlers(require('lzextras').lsp)

SHAPE 1: FUNCTION (runs for ALL LSP specs, shared setup)
┌─────────────────────────────────────────────────────────────┐
│  {                                                          │
│    "nvim-lspconfig",    ← the lspconfig plugin itself       │
│    lsp = function(plugin)                                   │
│      -- plugin.name = server name (from table specs)        │
│      -- plugin.lsp  = the table spec                        │
│      vim.lsp.config(plugin.name, plugin.lsp or {})          │
│      vim.lsp.enable(plugin.name)                            │
│    end,                                                     │
│    ft = { "lua", "nix", "python", ... },  ← all filetypes   │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
         │
         │
Runs BEFORE table specs 
         │
         ▼
SHAPE 2: TABLE (per server)
┌─────────────────────────────────────────────────────────────┐
│  { "lua_ls",                                                │
│    lsp = {                                                  │
│      filetypes = { "lua" },    ← lazy trigger              │
│      settings = { Lua = { workspace = { library = ... } } }│
│    }                                                        │
│  },                                                         │
│  { "nixd",                                                  │
│    lsp = {                                                  │
│      filetypes = { "nix" },                                 │
│      settings = { nixd = { ... } }                          │
│    }                                                        │
│  },                                                         │
└─────────────────────────────────────────────────────────────┘

EXECUTION FLOW:
  File opened (e.g., foo.lua)
    → handler detects ft = "lua"
    → calls function spec: vim.lsp.config("lua_ls", { settings=... })
    → calls function spec: vim.lsp.enable("lua_ls")
    → LSP attaches
```

---

## 6. `config.info` — Nix Data to Lua Pipeline

```
NIX (nvim.nix)                          LUA (init.lua / plugin configs)
──────────────────────────────────────────────────────────────────────
info = {                                local nix = require(
  categories = {                          vim.g.nix_info_plugin_name
    lua = true;                         )
    nix = true;
    python = false;                     -- Safe nested access:
  };                                    -- nix(default, "key1", "key2", ...)
  formatters = {
    fast = { ... };     ──────────►    local cats = nix(nil, "categories")
    slow = { ... };                    local hasLua = nix(false,
  };                                             "categories", "lua")
  linters = { ... };
  nixdExtras.nixpkgs =  ──────────►    local fmts = nix({},
    "import ${pkgs.path} {}";                   "formatters", "fast")
};
                                       -- nixd uses this for eval:
                                       -- nix(nil, "nixdExtras", "nixpkgs")
```

---

## 7. Nix Wrapper Module Option Hierarchy

```
wlib.wrapperModules.neovim
│
├─ package                 (nvim-unwrapped derivation)
│
├─ specs                   ← _plugins.nix (per-plugin)
│   ├─ data                (plugin package)
│   ├─ lazy                (start/ vs opt/)
│   ├─ enable              (include/exclude)
│   ├─ config              (Lua/Vim/Fennel code)
│   ├─ info                (Nix values → config)
│   ├─ before / after      (DAG ordering)
│   └─ [specMods fields]   (pluginDeps, runtimeDeps, ...)
│
├─ info                    ← arbitrary Nix data → require(nix_info_plugin_name)
│
├─ settings
│   ├─ aliases             (["vim"] → bin/vim symlink)
│   ├─ config_directory    (where init.lua lives)
│   ├─ block_normal_config (skip ~/.config/nvim)
│   └─ dont_link           (avoid collisions)
│
├─ extraPackages           ← LSPs, formatters, linters on PATH
│
├─ hosts
│   ├─ python3.nvim-host.enable = true
│   └─ node.nvim-host.enable = true
│
├─ specMods                (declare extra spec fields + defaults)
├─ specMaps                (transform entire spec structure)
└─ specCollect             (accumulate values from specs)
```

---

## 8. Adding a New Plugin — Decision Tree

```lua
Want to add a plugin?
         │
         ├─ Does it need lazy loading? (large plugin, specific filetype, etc.)
         │      │
         │  YES │                                NO
         │      ▼                                 ▼
         │  _plugins.nix:                    _plugins.nix:
         │  key = { data = pkg;              key = { data = pkg;
         │          lazy = true; };                   lazy = false; };
         │      │                                 │
         │      │                           Done. Plugin auto-loads at startup.
         │      ▼
         │  lua/plugins/X.lua — add to lze.load({...}):
         │  {
         │    "nix-key-name",    ← must match _plugins.nix key
         │    ft / event / keys / cmd,   ← pick trigger(s)
         │    after = function()
         │      require("lua-module-name").setup({})
         │                ↑
         │      Check plugin's lua/ dir on GitHub!
         │    end,
         │  }
         │
         ├─ Is it an LSP server?
         │      │
         │      ▼
         │  _lang-defs.nix: add binary to packages[]
         │  lua/config/lsp.lua: add table spec
         │  {
         │    "server-name",
         │    lsp = { filetypes = { "..." }, settings = { ... } }
         │  }
         │
         └─ Does it need Nix-generated config values?
                │
                ▼
            nvim.nix: add to info = { ... }
            Lua: local nix = require(vim.g.nix_info_plugin_name)
                 local val = nix(default, "your-key")
```

---

## 9. Our Config File Map

```
modules/nvim/
  nvim.nix              ← DEN ASPECT: wlib.evalPackage entry point
  _plugins.nix          ← ALL plugin declarations (Nix key → { data, lazy })
  _lang-defs.nix        ← Language definitions: packages, LSPs, formatters, linters
  _nvim_nixcats.nix     ← (legacy? or helper)
  init.lua              ← Neovim entry point (settings.config_directory = ./)
  lua/
    config/
      lsp.lua           ← lzextras LSP handler specs (function + table specs)
      ...
    plugins/
      ui.lua            ← lze.load() specs for UI plugins
      coding.lua        ← lze.load() specs for coding plugins
      ...
```

```
DATA FLOW:
nvim.nix
  ├─ specs    ←── _plugins.nix (what's available in packpath)
  ├─ info     ←── { categories, formatters, linters } (from _lang-defs.nix)
  └─ extraPkgs ←── _lang-defs.nix packages (LSPs etc. on PATH)

init.lua
  └─ require('lze').load(...)  ←── lua/plugins/*.lua (what/when to load)
       └─ lsp handler          ←── lua/config/lsp.lua (LSP server configs)
```
