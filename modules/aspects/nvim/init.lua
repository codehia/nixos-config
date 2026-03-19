vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- NIX INFO HELPER (replaces nixCats API)
local _nix = require(vim.g.nix_info_plugin_name)
_G.nix_has_feature = function(name)
  return _nix(false, 'info', 'categories', name) == true
end
_G.nix_info = function(...)
  return _nix(nil, 'info', ...)
end

-- Load config modules
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- LSP (native Neovim 0.11)
require('config.lsp').setup()

-- lzextras.mod_dir_to_spec auto-discovers all files under lua/plugins/ and generates
-- an import spec for each. New plugin files are picked up without editing init.lua.
require('lze').load(require('lzextras').mod_dir_to_spec('plugins'))
