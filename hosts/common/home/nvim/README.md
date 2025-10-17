# Neovim Configuration (nixCats)

This is a Neovim configuration using [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim) with home-manager integration.

## Structure

```
nvim/
├── init.lua                      # Main configuration file (~1100 lines)
├── default.nix                   # nixCats configuration
├── lua/                          # Modular files (for reference, not currently used)
│   ├── config/                   # Core configuration modules
│   └── plugins/                  # Plugin configurations
└── README.md                     # This file
```

**Note**: While modular files exist in `lua/`, the current setup uses a single `init.lua` for simplicity and compatibility with nixCats' `wrapRc` mode.

## Features

### Core
- **Plugin Manager**: `lze` for lazy loading
- **Colorscheme**: Catppuccin (Mocha flavor)
- **Statusline**: mini.statusline
- **File Explorer**: Snacks explorer & Oil.nvim
- **Fuzzy Finder**: Snacks picker & Telescope
- **Git Integration**: Gitsigns, Snacks lazygit

### LSP Support
- **Lua**: lua_ls + stylua
- **Nix**: nixd + alejandra
- **Python**: basedpyright + flake8/autopep8 (preferred) or ruff/black (fallback)
- **TypeScript/JavaScript**: ts_ls + prettier + eslint_d
- **Go**: gopls (optional, disabled by default)

### GitHub Copilot
GitHub Copilot and Copilot Chat are **disabled by default** to save resources. 

#### Enable Copilot
Press `<leader>tc` to toggle Copilot on/off.

#### Enable Copilot Chat
Press `<leader>tC` to toggle Copilot Chat window.

#### Copilot Keymaps
- `<C-l>` (insert mode): Accept Copilot suggestion
- `<C-j>` (insert mode): Next Copilot suggestion
- `<C-k>` (insert mode): Previous Copilot suggestion
- `<C-h>` (insert mode): Dismiss Copilot suggestion

#### Copilot Chat Keymaps
- `<leader>tC`: Toggle Copilot Chat
- `<leader>ccq`: Quick chat (ask a question)
- `<leader>cch`: Show help actions
- `<leader>ccp`: Show prompt actions
- `<leader>ccb`: Explain current buffer
- `<leader>ccx`: Explain diagnostic

**Visual mode prompts:**
- `<leader>cce`: Explain selected code
- `<leader>ccr`: Review selected code
- `<leader>ccf`: Fix selected code
- `<leader>cco`: Refactor selected code
- `<leader>cct`: Generate tests for selected code
- `<leader>ccd`: Generate documentation for selected code

## Key Mappings

### Leader Key
`<Space>` is the leader key.

### Which-Key Groups
Press `<leader>` to see all available key mappings organized into groups:
- `<leader><leader>`: Buffer commands
- `<leader>c`: Code actions
- `<leader>cc`: Copilot Chat commands
- `<leader>d`: Document/diagnostics
- `<leader>f`: Find/file operations
- `<leader>g`: Git operations
- `<leader>gt`: Git toggles
- `<leader>r`: Rename
- `<leader>s`: Search
- `<leader>t`: Toggles
- `<leader>w`: Workspace

### LSP (when in a buffer with LSP attached)
- `gd`: Go to definition
- `gr`: Go to references
- `gI`: Go to implementation
- `gD`: Go to declaration
- `K`: Hover documentation
- `<leader>ca`: Code action
- `<leader>rn`: Rename symbol
- `<leader>ds`: Document symbols
- `<leader>ws`: Workspace symbols
- `<leader>th`: Toggle inlay hints

### File Navigation
- `<leader>ff`: Find files
- `<leader>fg`: Find git files
- `<leader>sf`: Smart find (snacks)
- `<leader>sg`: Live grep
- `<leader>sb`: Search buffer lines
- `-`: Open file explorer (Snacks)
- `<leader>-`: Open file explorer (Oil)

### Git
- `<leader>gg`: Open Lazygit
- `<leader>gb`: Git branches
- `<leader>gl`: Git log
- `<leader>gs`: Git status
- `<leader>gp`: Preview git hunk
- `<leader>gs`: Stage git hunk
- `<leader>gr`: Reset git hunk
- `]c`, `[c`: Next/previous git hunk

### Buffers
- `<S-h>`: Previous buffer
- `<S-l>`: Next buffer
- `<leader>bd`: Delete buffer
- `<leader>bb`: Switch to other buffer

### Toggles
- `<leader>tc`: Toggle Copilot
- `<leader>tC`: Toggle Copilot Chat
- `<leader>th`: Toggle inlay hints
- `<leader>tb`: Toggle git blame line

### Formatting & Linting
- `<leader>FF`: Format file
- Linting happens automatically on save

## Configuration

### Enable/Disable Language Support

Edit `hosts/common/home/nvim/default.nix` and modify the `categories` section:

```nix
categories = {
  general = true;
  lua = true;
  nix = true;
  python = true;      # Set to false to disable Python support
  typescript = true;  # Set to false to disable TypeScript support
  go = false;         # Set to true to enable Go support
};
```

### Add New Plugins

1. Add the plugin package to `optionalPlugins` in `default.nix`:
```nix
optionalPlugins = {
  general = with pkgs.vimPlugins; [
    # ... existing plugins
    your-new-plugin
  ];
};
```

2. Configure the plugin in the appropriate module:
   - UI plugins → `lua/plugins/ui.lua`
   - Editor plugins → `lua/plugins/editor.lua`
   - Coding plugins → `lua/plugins/coding.lua`

3. Add plugin configuration using lze format:
```lua
{
  'plugin-name',
  event = 'VeryLazy',  -- or other lazy loading triggers
  after = function()
    require('plugin-name').setup({
      -- your configuration
    })
  end,
}
```

## Troubleshooting

### Plugin Not Loading
Check if the plugin is in the correct category in `default.nix` and that category is enabled.

### LSP Not Working
1. Verify the language category is enabled in `categories`
2. Check if the LSP server is in `lspsAndRuntimeDeps`
3. Run `:LspInfo` to see LSP status

### Copilot Not Working
1. Make sure you've enabled Copilot with `<leader>tc`
2. You may need to authenticate with GitHub the first time: `:Copilot auth`

## Performance

The configuration uses lazy loading extensively to minimize startup time:
- Most plugins are loaded on-demand via `lze`
- LSP servers start only when opening relevant file types
- Treesitter loads after UI is ready
- Copilot is completely disabled until explicitly enabled

## Updates

To update all plugins, rebuild your NixOS configuration:
```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .
```
