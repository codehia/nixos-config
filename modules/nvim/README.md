# Neovim Configuration

Managed via [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)
(`BirdeeHub/nix-wrapper-modules`). Plugins and LSP tools are declared in Nix;
all runtime config is standard Lua.

The built package is available as `vim` (alias) and `nvim` (main binary).

---

## File Structure

```
modules/nvim/
├── nvim.nix          # Aspect definition — wires nix-wrapper-modules into den.aspects.nvim
├── _lang-defs.nix    # per-language packages, formatters, linters (consumed by nvim.nix)
├── _plugins.nix      # specs: vim plugins with lazy/start flags
├── init.lua          # Entry point — loads config modules and plugins
└── lua/
    ├── config/
    │   ├── options.lua   # Neovim options (number, clipboard, etc.)
    │   ├── keymaps.lua   # General keymaps (non-plugin)
    │   ├── autocmds.lua  # Autocommands
    │   └── lsp.lua       # LSP setup: on_attach + server configs (native Neovim 0.11)
    └── plugins/
        ├── ui.lua        # UI plugins (catppuccin, mini, snacks, noice, etc.)
        ├── editor.lua    # Editor plugins (telescope, treesitter, gitsigns, etc.)
        └── coding.lua    # Coding plugins (completion, formatting, linting, AI, debug)
```

> Files prefixed with `_` are excluded from `import-tree` auto-discovery.
> `_lsps.nix` and `_plugins.nix` are plain Nix functions, not modules.

---

## How It Works

### Nix layer (`nvim.nix`)

```nix
{ inputs, ... }: let
  wlib = inputs.wrappers.lib;
in {
  flake-file.inputs.wrappers.url = "github:BirdeeHub/nix-wrapper-modules";

  den.aspects.nvim.homeManager = { pkgs, ... }: let
    nvimPkg = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.neovim-unwrapped;
  in {
    home.packages = [
      (wlib.evalPackage [
        { inherit pkgs; }
        ({ pkgs, wlib, ... }: {
          imports = [ wlib.wrapperModules.neovim ];   # neovim wrapper module
          package                      = nvimPkg;     # neovim binary from nixpkgs-unstable
          settings.aliases             = [ "vim" ];   # 'nvim' is the main binary; 'vim' is the alias
          settings.config_directory    = ./.;         # directory containing init.lua
          settings.block_normal_config = true;        # ignore ~/.config/nvim
          extraPackages                = import ./_lsps.nix { inherit pkgs; };
          specs                        = import ./_plugins.nix { inherit pkgs; };
          info = {                                    # data exposed to Lua via nix-info
            nixdExtras.nixpkgs = "import ${pkgs.path} {}";
            categories = {
              general = true; lua = true; nix = true; python = true; typescript = true; go = false;
            };
          };
          hosts.python3.nvim-host.enable = true;
          hosts.node.nvim-host.enable    = true;
        })
      ])
    ];
  };
}
```

### Lua layer

**nix-info** bridges Nix data into Lua. The top-level table returned by `require("nix-info")`
has an `info` key containing the data declared in `nvim.nix`:

```lua
local _nix = require(vim.g.nix_info_plugin_name)
-- IMPORTANT: must include "info" prefix — data is nested under self.info
_G.nix_has_feature = function(name) return _nix(false, "info", "categories", name) == true end
_G.nix_info = function(...) return _nix(nil, "info", ...) end
```

| Lua call | Returns |
|---|---|
| `nix_has_feature("lua")` | `true` (category enabled) |
| `nix_has_feature("go")` | `false` (go category disabled) |
| `nix_info("nixdExtras", "nixpkgs")` | nixpkgs import expression string |

### LSP setup (native Neovim 0.11)

LSP is configured in `lua/config/lsp.lua` using Neovim 0.11's built-in API — no lzextras
handler or nvim-lspconfig hook pattern. Each server is fully self-contained with `cmd`,
`filetypes`, and `root_markers`:

```lua
vim.lsp.config("*", { on_attach = M.on_attach })
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".stylua.toml", ".git" },
  settings = { ... },
})
vim.lsp.enable({ "lua_ls", "nixd", ... })
```

> nvim-lspconfig is in `opt/` (lazy), so its `lsp/` runtime files are NOT on the
> runtime path. All server configs must include `cmd`, `filetypes`, and `root_markers`
> explicitly.

---

## Plugins (`_plugins.nix`)

Plugins are declared as a Nix attrset of specs. Each spec has at minimum `data` (the
vimPlugin derivation) and `lazy` (whether to place in `opt/` vs `start/`).

```nix
{ pkgs }: with pkgs.vimPlugins; {
  # lazy = false  →  start/ (loaded at startup)
  lze     = { data = lze;        lazy = false; };
  snacks  = { data = snacks-nvim; lazy = false; };

  # lazy = true   →  opt/ (loaded on demand by lze in init.lua)
  oil     = { data = oil-nvim;   lazy = true; };
}
```

### Adding a plugin

**Example: adding `nvim-autopairs`**

1. Find the Nix package name:
   ```bash
   nix search nixpkgs vimPlugins.nvim-autopairs
   ```

2. Add to `_plugins.nix` (choose `lazy = true` for on-demand, `false` for startup):
   ```nix
   autopairs = { data = nvim-autopairs; lazy = true; };
   ```

3. Add an lze spec to the appropriate file in `lua/plugins/`. Pick the file by
   category — `ui.lua` for visual, `editor.lua` for navigation/editing,
   `coding.lua` for LSP/completion/AI. The spec name (first element) must match
   the plugin's `pname` attribute:
   ```lua
   -- in lua/plugins/coding.lua, inside the return table:
   {
       "nvim-autopairs",
       event = "InsertEnter",        -- lazy-load trigger
       after = function()            -- runs after plugin loads
           require("nvim-autopairs").setup({
               check_ts = true,
           })
       end,
   },
   ```

4. Run `just install`.

**lze spec triggers** (only one needed per spec):

| Field | When it loads | Example |
|---|---|---|
| `event` | On vim event | `"InsertEnter"`, `"BufReadPost"`, `"DeferredUIEnter"` |
| `cmd` | On vim command | `"Telescope"`, `{ "Octo", "OctoList" }` |
| `keys` | On keymap | `{ { "<leader>ff", desc = "Find files" } }` |
| `ft` | On filetype | `"lua"`, `{ "python", "rust" }` |
| `dep_of` | Before parent loads | `{ "telescope.nvim" }` |
| `on_plugin` | After parent loads | `{ "nvim-treesitter" }` |
| `lazy = false` | At startup (in spec) | — |

**How to find the pname:** check the plugin's nixpkgs derivation or run
`nix eval nixpkgs#vimPlugins.nvim-autopairs.pname`. The spec name must match
this value or lze won't find the plugin in the packdir.

### Removing a plugin

1. Delete the spec entry from `_plugins.nix`.
2. Remove the lze spec from the corresponding `lua/plugins/*.lua` file.
3. Run `just install`.

---

## Editing Configuration

### Changing vim options

Edit `lua/config/options.lua`:
```lua
vim.o.number         = true
vim.o.relativenumber = true
vim.opt.clipboard    = "unnamedplus"
```

### Changing keymaps

Edit `lua/config/keymaps.lua` for general keymaps. Plugin-specific keymaps
live in their lze spec's `after` function in `lua/plugins/*.lua`.

### Changing plugin settings

Find the plugin's lze spec in `lua/plugins/ui.lua`, `editor.lua`, or `coding.lua`
and edit the `after` (or `before`) function:

```lua
{
    "gitsigns.nvim",
    event = "BufReadPost",
    after = function()
        require("gitsigns").setup({
            signs = { add = { text = "+" } },  -- edit settings here
        })
    end,
},
```

### Adding a new LSP server

Two files need editing:

1. **`_lsps.nix`** — add the server binary to `extraPackages`:
   ```nix
   { pkgs }: with pkgs; [
     # ... existing packages ...
     rust-analyzer   # add the LSP binary
   ]
   ```

2. **`lua/config/lsp.lua`** — add the server config in `M.setup()`:
   ```lua
   if nix_has_feature("rust") then
       vim.lsp.config("rust_analyzer", {
           cmd = { "rust-analyzer" },
           filetypes = { "rust" },
           root_markers = { "Cargo.toml", ".git" },
           settings = {
               ["rust-analyzer"] = {
                   check = { command = "clippy" },
               },
           },
       })
   end
   ```
   And add it to the `vim.lsp.enable()` list at the bottom:
   ```lua
   if nix_has_feature("rust") then table.insert(servers, "rust_analyzer") end
   ```

3. **`nvim.nix`** — add the category (optional, for gating):
   ```nix
   categories = {
     # ... existing ...
     rust = true;
   };
   ```

4. Run `just install`.

> Every server needs `cmd`, `filetypes`, and `root_markers` explicitly.
> nvim-lspconfig is in `opt/` so its defaults are NOT available.

### Adding a formatter or linter

1. Add the binary to `_lsps.nix` (it goes on the wrapper's PATH).
2. Edit `lua/plugins/coding.lua`:
   - For formatters: add to `conform.nvim`'s `formatters_by_ft` table.
   - For linters: add to `nvim-lint`'s `linters_by_ft` table.
3. Run `just install`.

---

## LSP Tools (`_lsps.nix`)

`extraPackages` is a plain list of packages added to the wrapper's `PATH`. This is how
LSP servers, formatters, and linters are made available to neovim without installing
them globally.

```nix
{ pkgs }: with pkgs; [
  lazygit git ripgrep fd fzf fortune cowsay universal-ctags gnumake gcc
  lua-language-server stylua
  nixd alejandra
  basedpyright python3Packages.flake8 ruff python3Packages.autopep8 black isort
  typescript-language-server nodePackages.prettier eslint_d
  shfmt shellcheck markdownlint-cli
  gopls delve golangci-lint go
  gh   # for octo.nvim
]
```

### Adding/removing an LSP tool

Edit `_lsps.nix` and run `just install`. No other change needed — the package will
automatically be on `PATH` inside neovim.

---

## Categories (`info.categories`)

Categories gate Lua config behind a runtime check. Set in `nvim.nix` under `info.categories`:

| Category | Enabled | Gates |
|---|---|---|
| `general` | `true` | most plugins |
| `lua` | `true` | lua_ls server, lazydev |
| `nix` | `true` | nixd server |
| `python` | `true` | basedpyright server |
| `typescript` | `true` | ts_ls server |
| `go` | `false` | gopls server, dap-go, golangci-lint |

In Lua, gate code with `nix_has_feature("go")`:

```lua
{
  "nvim-dap-go",
  enabled = nix_has_feature("go"),
  ...
}
```

To enable Go support: set `go = true;` in `nvim.nix` → `just install`.

---

## Environment Variables

| Variable | Used by | How to set |
|---|---|---|
| `ANTHROPIC_API_KEY` | avante.nvim | sops-nix secret or shell session |
| `GITHUB_TOKEN` | octo.nvim | sops-nix secret or shell session |

---

## Rebuild

`config_directory = ./.` is a Nix path literal — Lua files are copied to the nix
store at build time. **All changes (Lua or Nix) require `just install`.**

| Change | Requires `just install`? |
|---|---|
| Edit any Lua file | **Yes** |
| Add/remove plugin in `_plugins.nix` | **Yes** |
| Add/remove LSP tool in `_lsps.nix` | **Yes** |
| Change `info.categories` in `nvim.nix` | **Yes** |
