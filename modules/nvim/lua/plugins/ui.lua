-- =============================================================================
-- UI PLUGINS
-- =============================================================================

return {
	-- ---------------------------------------------------------------------------
	-- Catppuccin — colorscheme (loaded immediately)
	-- ---------------------------------------------------------------------------
	{
		"catppuccin-nvim",
		lazy = false,
		priority = 1000,
		after = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = false,
				show_end_of_buffer = false,
				term_colors = false,
				dim_inactive = { enabled = false },
				styles = {
					comments = { "italic" },
					conditionals = { "italic" },
				},
				integrations = {
					blink_cmp = true,
					gitsigns = true,
					mini = { enabled = true },
					treesitter = true,
					which_key = true,
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
						inlay_hints = { background = true },
					},
					telescope = { enabled = true },
					lsp_trouble = true,
					indent_blankline = { enabled = true },
					navic = { enabled = true },
					noice = true,
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Mini — starter, statusline, pairs, icons, ai, surround
	-- ---------------------------------------------------------------------------
	{
		"mini.nvim",
		lazy = false,
		after = function()
			-- Mini.starter for start screen
			local starter = require("mini.starter")
			local function get_header()
				local handle = io.popen("fortune -s | cowsay")
				if not handle then
					return "Welcome to Neovim!"
				end
				local result = handle:read("*a")
				handle:close()
				return result or "Welcome to Neovim!"
			end

			starter.setup({
				header = get_header(),
				items = {
					starter.sections.recent_files(5, false),
					starter.sections.recent_files(5, true),
					starter.sections.builtin_actions(),
				},
				content_hooks = {
					starter.gen_hook.adding_bullet(),
					starter.gen_hook.aligning("center", "center"),
				},
			})

			-- Mini.statusline
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- Mini.pairs for auto-pairing brackets
			require("mini.pairs").setup()

			-- Mini.icons
			require("mini.icons").setup()

			-- Mini.ai for better text objects
			require("mini.ai").setup({ n_lines = 500 })

			-- Mini.surround for surround operations
			require("mini.surround").setup()
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Snacks — notifier, lazygit, bigfile (NOT picker/explorer)
	-- ---------------------------------------------------------------------------
	{
		"snacks.nvim",
		lazy = false,
		before = function()
			require("snacks").setup({
				dashboard = { enabled = false },
				bigfile = { enabled = true },
				notifier = { enabled = true, timeout = 3000 },
				quickfile = { enabled = true },
				lazygit = { enabled = true },
				git = { enabled = true },
			})

			vim.keymap.set("n", "<leader>gg", function()
				Snacks.lazygit()
			end, { desc = "Lazygit" })
			vim.keymap.set("n", "<leader>gl", function()
				Snacks.lazygit.log()
			end, { desc = "Lazygit Log" })
			vim.keymap.set({ "n", "v" }, "<leader>gB", function()
				Snacks.gitbrowse()
			end, { desc = "Git Browse" })
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Which-Key — keymap hints
	-- ---------------------------------------------------------------------------
	{
		"which-key.nvim",
		event = "DeferredUIEnter",
		after = function()
			require("which-key").setup()
			require("which-key").add({
				{ "<leader>a", group = "[A]I" },
				{ "<leader>b", group = "[B]uffer" },
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>d", group = "[D]ocument / Debug" },
				{ "<leader>f", group = "[F]ile" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>gt", group = "[G]it [T]oggle" },
				{ "<leader>h", group = "Git [H]unk" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>x", group = "Diagnostics/Quickfi[x]" },
				{ "<leader>z", group = "[Z]en" },
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Dressing — better vim.ui.select and vim.ui.input
	-- ---------------------------------------------------------------------------
	{
		"dressing.nvim",
		lazy = false,
		after = function()
			require("dressing").setup()
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Noice — cmdline, messages, popupmenu UI
	-- ---------------------------------------------------------------------------
	{
		"noice.nvim",
		lazy = false,
		after = function()
			require("noice").setup({
				cmdline = { enabled = true },
				messages = { enabled = true },
				popupmenu = { enabled = true },
				notify = { enabled = false }, -- snacks.notifier handles vim.notify
				lsp = {
					hover = { enabled = false }, -- lspsaga handles hover
					signature = { enabled = false }, -- blink-cmp handles signature
					progress = { enabled = true },
					message = { enabled = true },
					documentation = { enabled = true },
				},
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = true,
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Lspkind — vscode-style completion icons (dep of blink-cmp)
	-- ---------------------------------------------------------------------------
	{
		"lspkind.nvim",
		dep_of = { "blink.cmp" },
		lazy = true,
	},

	-- ---------------------------------------------------------------------------
	-- Indent-blankline — indent guides
	-- ---------------------------------------------------------------------------
	{
		"indent-blankline.nvim",
		event = "BufReadPost",
		after = function()
			require("ibl").setup({
				indent = { char = "│", tab_char = "│" },
				scope = { enabled = true, show_start = false, show_end = false },
				exclude = {
					filetypes = {
						"help",
						"dashboard",
						"Trouble",
						"trouble",
						"notify",
						"starter",
					},
				},
			})
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Nvim-navic — breadcrumbs in winbar
	-- ---------------------------------------------------------------------------
	{
		"nvim-navic",
		event = "DeferredUIEnter",
		after = function()
			require("nvim-navic").setup({
				icons = {
					File = "󰈙 ",
					Module = " ",
					Namespace = "󰌗 ",
					Package = " ",
					Class = "󰌗 ",
					Method = "󰆧 ",
					Property = " ",
					Field = " ",
					Constructor = " ",
					Enum = "󰕘 ",
					Interface = "󰕘 ",
					Function = "󰊕 ",
					Variable = "󰆧 ",
					Constant = "󰏿 ",
					String = " ",
					Number = "󰎠 ",
					Boolean = "◩ ",
					Array = "󰅪 ",
					Object = "󰅩 ",
					Key = "󰌋 ",
					Null = "󰟢 ",
					EnumMember = " ",
					Struct = "󰌗 ",
					Event = " ",
					Operator = "󰆕 ",
					TypeParameter = "󰊄 ",
				},
				lsp = { auto_attach = false },
				highlight = true,
				separator = " > ",
				depth_limit = 0,
				depth_limit_indicator = "..",
				safe_output = true,
				click = true,
			})
			vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
		end,
	},

	-- ---------------------------------------------------------------------------
	-- Vim-startuptime — :StartupTime profiler
	-- ---------------------------------------------------------------------------
	{
		"vim-startuptime",
		cmd = { "StartupTime" },
		before = function()
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
		end,
	},

	-- Dependencies loaded by lze before their parent plugins
	{ "nui.nvim", dep_of = { "noice.nvim" } },
}
