# Neovim

## Adding a plugin

### Step 1 — add to `_plugins.nix`

```nix
# modules/aspects/nvim/_plugins.nix
hardtime = {
  data = hardtime-nvim;   # pkgs.vimPlugins.hardtime-nvim
  lazy = false;           # false = start/ (auto-loaded); true = opt/ (lze loads on demand)
};
```

Use `lazy = true` for everything except plugins that must be available immediately
(colorscheme, snacks, the lazy loader itself).

### Step 2 — find the exact pname

The pname is the store directory name — what lze uses to identify the plugin. It doesn't
always match the nixpkgs attribute name.

```bash
find /nix/store -maxdepth 3 -name "vimplugin-*hardtime*" -type d
# → /nix/store/xxxxxxxx-vimplugin-hardtime.nvim-2024-11-25
# pname = hardtime.nvim
```

Common examples:

| nixpkgs attr (`pkgs.vimPlugins.*`) | pname (use in lze) |
|------------------------------------|---------------------|
| `hardtime-nvim` | `hardtime.nvim` |
| `markview-nvim` | `markview.nvim` |
| `snacks-nvim` | `snacks.nvim` |
| `nvim-lspconfig` | `nvim-lspconfig` |
| `blink-cmp` | `blink-cmp` |
| `telescope-nvim` | `telescope.nvim` |

### Step 3 — add the Lua spec in `lua/plugins/`

```lua
{
  'hardtime.nvim',        -- must match pname from step 2
  event = 'VeryLazy',
  after = function()
    require('hardtime').setup({ enabled = true })
  end,
},
```

Common triggers:

| Trigger | When it loads |
|---------|--------------|
| `event = 'DeferredUIEnter'` | after UI is ready — good for most plugins |
| `event = 'VeryLazy'` | very late startup |
| `ft = { 'lua', 'python' }` | when a filetype opens |
| `cmd = 'Telescope'` | when a user command is invoked |
| `keys = { '<leader>f' }` | when a keybind is triggered |

### Step 4 — rebuild

```bash
just install
```

---

## Adding an LSP / language tool

Add the language to `_lang-defs.nix`:

```nix
# modules/aspects/nvim/_lang-defs.nix
rust = {
  packages = with pkgs; [ rust-analyzer rustfmt clippy ];
  formatters.fast = { rust = [ "rustfmt" ]; };
  linters = { rust = [ "clippy" ]; };
};
```

Add the language to `nvimLanguages` in the host declaration:

```nix
# modules/hosts/personal/default.nix
nvimLanguages = [ "lua" "nix" "python" "rust" ];
```

Add the LSP config to `lua/config/lsp.lua` guarded by a category check:

```lua
local nix = require(vim.g.nix_info_plugin_name)
if nix(false, 'categories', 'rust') then
  vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml' },
  })
end
```

---

## Per-user language override

`nvimLanguages` is set per host and can be overridden per user:

```nix
den.hosts.x86_64-linux.thinkpad = {
  nvimLanguages = [ "lua" "nix" "python" "typescript" "go" "latex" ];

  users.soumya = {
    nvimLanguages = [ "nix" "lua" "python" "typescript" ];
  };
};
```
