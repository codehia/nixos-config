# nix-wrapper-modules + lze + lzextras — Research Notes

> Researched: 2026-03-14
> Sources:
> - https://birdeehub.github.io/nix-wrapper-modules/md/intro.html
> - https://birdeehub.github.io/nix-wrapper-modules/wrapperModules/neovim.html
> - https://github.com/BirdeeHub/lze
> - https://github.com/BirdeeHub/lzextras
> - Our config: `modules/nvim/nvim.nix`, `modules/nvim/_plugins.nix`

---

## What is nix-wrapper-modules?

A Nix library that wraps executables using the module system. Solves the problem of
reconfiguring programs for every platform (NixOS, home-manager, nix-darwin, devenv).

For Neovim specifically: it builds a wrapped `nvim` derivation that has plugins baked in,
configs pre-loaded, LSPs on PATH, and info metadata accessible from Lua — all declared in Nix.

Entry point in our config:
```nix
wlib.evalPackage [
  { inherit pkgs; }
  ({ pkgs, wlib, ... }: {
    imports = [ wlib.wrapperModules.neovim ];
    ...
  })
]
```

---

## nix-wrapper-modules Neovim Module

### Top-Level Options

| Option | Type | Purpose |
|--------|------|---------|
| `package` | derivation | The neovim-unwrapped package to wrap |
| `specs` | attrset of specs | Plugin declarations (see below) |
| `info` | attrset | Nix data exposed to Lua at runtime |
| `settings` | module | Wrapper behavior (aliases, config dir, etc.) |
| `hosts` | module | Remote plugin hosts (python3, node, etc.) |
| `extraPackages` | list | Extra binaries added to PATH |
| `specMods` | module | Declare extra spec fields / defaults |
| `specMaps` | list of fns | Transform the entire spec structure |
| `specCollect` | fn | Accumulate values from processed specs |

### `settings` sub-options

| Option | Purpose |
|--------|---------|
| `aliases` | Shell aliases for the binary (e.g., `["vim"]`) |
| `config_directory` | Where Neovim loads init.lua from (path) |
| `block_normal_config` | Prevent loading `~/.config/nvim` (default false) |
| `dont_link` | Avoid path collisions for multiple installs |
| `info_plugin_name` | Name of the Nix metadata plugin (default: "nix-info") |
| `compile_generated_lua` | Pre-compile generated Lua files |

### `hosts` sub-options

Each host (python3, node, ruby, neovide, etc.) supports:
- `nvim-host.enable = true` — adds host binary to PATH alongside nvim
- `enabled_variable` / `disabled_variable` — set vim globals automatically

In our config: `python3.nvim-host.enable = true` and `node.nvim-host.enable = true`.

---

## `config.specs` — Plugin Declarations

`specs` is an **attrset** of plugin specs. Each key becomes the plugin's Nix-side name.

### Three ways to write a spec

```nix
# 1. Bare package (simplest)
specs.gitsigns = pkgs.vimPlugins.gitsigns-nvim;

# 2. Spec object
specs.treesj = {
  data = pkgs.vimPlugins.treesj;
  lazy = true;
  config = "require('treesj').setup({})";
};

# 3. List of specs (for grouping)
specs.lsp-group = [
  { data = pkgs.vimPlugins.nvim-lspconfig; lazy = true; }
  { data = pkgs.vimPlugins.mason-nvim; lazy = true; }
];
```

### Built-in Spec Fields

| Field | Default | Purpose |
|-------|---------|---------|
| `data` | required | Plugin package/path |
| `lazy` | false | If true → placed in `opt/`, requires explicit load |
| `enable` | true | Include/exclude the plugin |
| `config` | — | Lua/Vim/Fennel code run after plugin loads |
| `type` | "lua" | Language for `config` (`"lua"`, `"vim"`, `"fnl"`) |
| `info` | — | Nix values passed to config handler |
| `pname` | (key name) | Override directory name in packpath |
| `name` | — | DAG name for `before`/`after` ordering |
| `before` | — | Run this spec's config before listed names |
| `after` | — | Run this spec's config after listed names |

#### Additional default fields (from specMods):

| Field | Default | Purpose |
|-------|---------|---------|
| `pluginDeps` | "startup" | How to install plugin deps |
| `collateGrammars` | true | Merge treesitter grammars into single tree |
| `runtimeDeps` | "suffix" | Add runtime deps to PATH |
| `autoconfig` | true | Use `.passthru.initLua` if present |

### Pack Directory Structure

```
pack/myNeovimPackages/
  start/<pname>/    ← lazy = false (loaded at startup automatically)
  opt/<pname>/      ← lazy = true  (must be loaded explicitly via packadd)
```

The DAG has a built-in `"INIT_MAIN"` node representing `init.lua`. All specs run after
`INIT_MAIN` by default. To run before init.lua: `before = [ "INIT_MAIN" ]`.

### `config.info` — Nix Data → Lua

```nix
info = {
  categories = { lua = true; nix = true; };
  formatters.fast = { ... };
  linters = { ... };
  nixdExtras.nixpkgs = "import ${pkgs.path} {}";
};
```

Access from Lua:
```lua
local nix = require(vim.g.nix_info_plugin_name)
local cats = nix(nil, "categories")   -- safe nested access
local hasPython = nix(false, "categories", "python")
```

The function signature is `nix(default, "key1", "key2", ...)` — returns default if path missing.

---

## lze — Lazy Loading Library

lze is a **pure Lua** lazy-loading library. It does NOT manage the packpath — that's
nix-wrapper-modules' job. lze only handles WHEN to call `vim.cmd.packadd(name)`.

### How it works

1. `require('lze').load(specs)` queues plugins
2. Handlers watch for trigger conditions (events, filetypes, keys, cmds)
3. When triggered, handler calls the load function: `vim.cmd.packadd(name)` (default)
4. Plugin is loaded; `after` hook runs; slot is marked as loaded

**Handlers have one chance** to prevent or modify a plugin before it enters the queue.

### Full Plugin Spec API (Lua side)

```lua
{
  -- Required
  "plugin-name",           -- [1]: directory name in packpath (opt/)

  -- Conditional
  enabled = true,          -- boolean or function → bool

  -- Lifecycle hooks
  beforeAll = function() end,  -- runs once before any plugins in this load() call
  before = function() end,     -- runs before THIS plugin loads
  after = function() end,      -- runs after THIS plugin loads
  load = function(name) end,   -- override default load mechanism per-plugin

  -- Ordering
  priority = 50,           -- startup order (higher = earlier); default 50

  -- Re-loading
  allow_again = false,     -- allow re-adding after first load

  -- Lazy triggers (handled by built-in handlers):
  lazy = true,             -- set automatically by handlers when triggers present
  event = "BufEnter",      -- string or table of autocmd events
  cmd = "MyCommand",       -- string or table of user commands
  ft = "python",           -- string or table of filetypes
  keys = { "<leader>f" },  -- string, table of strings, or key objects
  colorscheme = "catppuccin",  -- string or table of colorscheme names
  dep_of = "other-plugin", -- load BEFORE this plugin (as dependency)
  on_plugin = "snacks.nvim", -- load AFTER this plugin is loaded
  on_require = "snacks",   -- load when this Lua module is required
}
```

### Global Configuration

```lua
vim.g.lze = {
  injects = {},              -- defaults injected into all specs
  load = vim.cmd.packadd,    -- default load function
  verbose = true,            -- warn on duplicates/missing plugins
  default_priority = 50,
  without_default_handlers = false,
}
```

### Custom Events

```lua
-- DeferredUIEnter: fires after require('lze').load() completes AND UIEnter
-- Custom alias:
require('lze').h.event.set_event_alias("MyEvent", { event = "BufEnter", pattern = "*.lua" })
```

---

## lzextras — Extensions for lze

lzextras adds specialized handlers and utilities on top of lze.

### Setup (how our config uses it)

In `init.lua` (inferred from lzextras docs):
```lua
require('lze').register_handlers(require('lzextras').lsp)
-- Then lze specs can use the `lsp` field
```

### Extra Load Functions

| Function | Purpose |
|----------|---------|
| `lzextras.with_after` | Loads plugin + its `/after` directory |
| `lzextras.multi` | Loads multiple plugins from a list |
| `lzextras.multi_w_after` | Loads multiple plugins with `/after` dirs |
| `lzextras.debug_load` | Warns if plugins not found |

### Utilities

| Function | Purpose |
|----------|---------|
| `lzextras.mod_dir_to_spec(modname, filter?)` | Convert a module directory into lze import specs |
| `lzextras.key2spec(mode, lhs, rhs, opts)` | Convert keymap.set syntax to lze key spec |
| `lzextras.keymap(name_or_spec)` | Add keymap triggers after spec is registered |

### Handlers

#### LSP Handler (most important)

Registers a `lsp` field on lze specs. Handles two spec shapes:

```lua
-- Shape 1: FUNCTION — runs for ALL LSP specs (shared setup)
{
  "nvim-lspconfig",
  lsp = function(plugin)
    -- plugin.name = server name
    -- plugin.lsp = the table spec (if any)
    vim.lsp.config(plugin.name, plugin.lsp or {})
    vim.lsp.enable(plugin.name)
  end
}

-- Shape 2: TABLE — individual LSP server config
{
  "lua_ls",
  lsp = {
    filetypes = { "lua" },
    settings = { Lua = { ... } }
  }
}
```

**Execution order**: function-type specs run BEFORE table-type specs.
**Auto-filetypes**: if no `filetypes` specified, pulls from lspconfig's server config.
**Filetype fallback**: `require('lze').h.lsp.set_ft_fallback(filetypes)` — fallback if
  lspconfig can't auto-detect filetypes for a server.

The handler lazy-loads LSP servers by filetype — deferring initialization until a relevant
file is opened.

#### Merge Handler

```lua
require('lze').register_handlers(require('lzextras').merge)
```

Enables merging plugin specs from multiple sources. Useful for distributions or complex configs.

---

## How Our Config Ties It Together

### Nix Side (`nvim.nix` + `_plugins.nix`)

```
nvim.nix
  └─ wlib.evalPackage
       └─ wlib.wrapperModules.neovim
            ├─ package = nvim-unwrapped (from nixpkgs-unstable)
            ├─ specs = import _plugins.nix { inherit pkgs; }
            │    Each key → spec object with { data, lazy }
            │    lazy=false → start/  (auto-loaded)
            │    lazy=true  → opt/   (lze manages loading)
            ├─ info = { categories, formatters, linters, nixdExtras }
            │    Accessible in Lua via require(vim.g.nix_info_plugin_name)
            ├─ settings.config_directory = ./.
            │    Points to modules/nvim/ — init.lua loaded from here
            ├─ extraPackages = LSPs + tools from _lang-defs.nix
            └─ hosts = { python3, node } → added to PATH
```

### Lua Side (init.lua + lua/)

```
nvim starts
  → init.lua loaded (from settings.config_directory)
      → registers lzextras handlers (lsp, merge, etc.)
      → calls require('lze').load({ ... specs ... })
           Each spec: { "plugin-name", ft/event/keys/lsp = ... }
           Handler watches for trigger
           Trigger fires → vim.cmd.packadd("plugin-name")
           Plugin loads from opt/
           after() hook runs (setup calls go here)
```

### Plugin Name Mapping

There are **three distinct names** to track for each plugin:

1. **Nix key** — identifier in `_plugins.nix` attrset (arbitrary, for Nix use only)
2. **lze spec name** (`[1]` in the Lua spec) — must match the **actual packpath directory name**, which is derived from the nixpkgs package's `pname`, NOT the Nix key
3. **Lua require name** — whatever the plugin's `lua/` subdirectory is named (unrelated to either)

| Nix key | Nix package | lze spec name | Lua require |
|---------|-------------|---------------|-------------|
| `treesitter` | `nvim-treesitter` | `nvim-treesitter` | `require('nvim-treesitter')` |
| `markview` | `markview-nvim` | `markview.nvim` | `require('markview')` |
| `lspconfig` | `nvim-lspconfig` | `nvim-lspconfig` | `require('lspconfig')` |
| `blink-cmp` | `blink-cmp` | `blink-cmp` | `require('blink.cmp')` |
| `snacks` | `snacks-nvim` | `snacks.nvim` | `require('snacks')` |
| `hardtime` | `hardtime-nvim` | `hardtime.nvim` | `require('hardtime')` |

**Key rule**: nixpkgs Vim plugins named `foo-nvim` often have pname `foo.nvim` (hyphen→dot).
The lze spec name must match the pname — **not** the Nix key and **not** the nixpkgs attr name.

### Finding the Correct lze Spec Name

When adding a new plugin and unsure of the directory name, search the Nix store:

```bash
find /nix/store -maxdepth 3 -name "<plugin-pattern>*" -type d
```

Example for markview:
```
$ find /nix/store -maxdepth 3 -name "markview*" -type d
/nix/store/5bmgbg...-vimplugin-markview.nvim-2025-11-16/lua/markview
/nix/store/5bmgbg...-vimplugin-markview.nvim-2025-11-16/markview.nvim.wiki
```

The store path format is `vimplugin-<PNAME>-<VERSION>`. Extract just `<PNAME>` — that's your lze spec name.
Here: `markview.nvim` → use `'markview.nvim'` in the Lua spec.

You can also check the nixpkgs source for the plugin's `pname` attribute, or look at the
`meta.homepage` from `nix eval nixpkgs#vimPlugins.markview-nvim`.

---

## Adding a New Plugin (End-to-End)

### Step 1: Add to `_plugins.nix`

```nix
my-plugin = {
  data = pkgs.vimPlugins.my-plugin-nvim;
  lazy = true;   # or false for startup plugins
};
```

### Step 2: Add to Lua `lua/plugins/something.lua`

```lua
-- In the return table passed to require('lze').load(...)
{
  "my-plugin",           -- matches the Nix key (= packpath dir name)
  ft = { "rust" },       -- lazy trigger
  after = function()
    require("my-plugin-lua-name").setup({})  -- the PLUGIN's Lua module name
  end,
},
```

### Step 3 (if LSP): Use lzextras lsp handler

```nix
# _plugins.nix: just add the server binary to extraPackages via _lang-defs.nix
# No Nix plugin needed if server is standalone
```

```lua
-- Function spec (once, defines handler):
{ "nvim-lspconfig",
  lsp = function(plugin)
    vim.lsp.config(plugin.name, plugin.lsp or {})
    vim.lsp.enable(plugin.name)
  end,
  ft = { "lua", "nix", ... },
},

-- Table spec (per server):
{ "lua_ls",
  lsp = { filetypes = { "lua" }, settings = { Lua = { ... } } }
},
```

---

## Key Gotchas

1. **Lua module name ≠ Nix package name** — always check the plugin's `lua/` dir name
2. **`lazy = false` in Nix** = placed in `start/` = loaded at startup automatically (no lze needed)
3. **`lazy = true` in Nix** = placed in `opt/` = MUST be loaded explicitly (lze does this)
4. **lze spec name** `[1]` must match the **package pname** (packpath directory name), NOT the Nix key — use `find /nix/store -maxdepth 3 -name "<pattern>*" -type d` to find it; format is `vimplugin-<PNAME>-<version>`
5. **lzextras.lsp handler**: function-type spec MUST be defined before table-type specs in the load() call
6. **`before = ["INIT_MAIN"]`** in Nix spec = runs config code BEFORE init.lua
7. **info access**: always use the function form `nix(default, "key")` — direct indexing is unsafe
