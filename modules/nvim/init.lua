vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NIX INFO HELPER (replaces nixCats API)
local _nix = require(vim.g.nix_info_plugin_name)
_G.nix_has_feature = function(name)
	return _nix(false, "info", "categories", name) == true
end
_G.nix_info = function(...)
	return _nix(nil, "info", ...)
end

-- Load config modules
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- LSP (native Neovim 0.11)
require("config.lsp").setup()

-- Load plugins (each returns a table of lze specs)
require("lze").load(require("plugins.ui"))
require("lze").load(require("plugins.editor"))
require("lze").load(require("plugins.coding"))
