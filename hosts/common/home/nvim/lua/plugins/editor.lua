-- =============================================================================
-- EDITOR PLUGINS
-- =============================================================================

return {
	-- Fuzzy finder (telescope as alternative to snacks picker)
	{
		"telescope-nvim",
		event = "VeryLazy",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("telescope-fzf-native-nvim")
			vim.cmd.packadd("telescope-ui-select-nvim")
		end,
		after = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
						},
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable telescope extensions
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
		end,
	},

	-- Treesitter for better syntax highlighting
	{
		"nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})
		end,
	},

	-- Git signs
	{
		"gitsigns-nvim",
		event = { "BufReadPost", "BufNewFile" },
		after = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end, { desc = "Jump to next git [c]hange" })

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end, { desc = "Jump to previous git [c]hange" })

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
					map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "stage git hunk" })
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "reset git hunk" })
					map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
					map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "git [u]ndo stage hunk" })
					map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
					map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
					map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
					map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
					map("n", "<leader>hD", function()
						gitsigns.diffthis("@")
					end, { desc = "git [D]iff against last commit" })
					map(
						"n",
						"<leader>tb",
						gitsigns.toggle_current_line_blame,
						{ desc = "[T]oggle git show [b]lame line" }
					)
					map("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "[T]oggle git show [D]eleted" })
				end,
			})
		end,
	},

	-- File explorer
	{
		"oil-nvim",
		event = "VeryLazy",
		after = function()
			require("oil").setup({
				default_file_explorer = true,
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
					natural_order = true,
					is_always_hidden = function(name, _)
						return name == ".." or name == ".git"
					end,
				},
				float = {
					padding = 2,
					max_width = 90,
					max_height = 0,
				},
				win_options = {
					wrap = true,
					winblend = 0,
				},
				keymaps = {
					["<C-c>"] = false,
					["q"] = "actions.close",
				},
			})

			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set(
				"n",
				"<leader>-",
				require("oil").toggle_float,
				{ desc = "Open parent directory in floating window" }
			)
		end,
	},

	-- Better folding
	{
		"nvim-ufo",
		event = "BufReadPost",
		after = function()
			require("ufo").setup()
		end,
	},

	-- Auto-detect indentation
	{
		"vim-sleuth",
	},
}
