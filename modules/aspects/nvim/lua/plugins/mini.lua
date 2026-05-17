--[[
————————————————————————————————————————————————————————————
—— Mini — starter, statusline, pairs, icons, ai, surround ——
————————————————————————————————————————————————————————————
]]

return {
  'mini.nvim',
  lazy = false,
  after = function()
    -- Mini.starter for start screen
    local starter = require('mini.starter')
    local function get_header()
      local handle = io.popen('fortune -s | cowsay')
      if not handle then
        return 'Welcome to Neovim!'
      end
      local result = handle:read('*a')
      handle:close()
      return result
    end

    starter.setup({
      header = get_header(),
      items = {
        starter.sections.recent_files(5, true, false),
        starter.sections.builtin_actions(),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning('center', 'center'),
        starter.gen_hook.indexing('all', { 'Builtin actions' }),
        starter.gen_hook.padding(3, 2),
      },
      footer = '',
    })

    -- Mini.statusline
    vim.o.showcmdloc = 'statusline'
    local statusline = require('mini.statusline')
    statusline.setup({ use_icons = vim.g.have_nerd_font })

    -- Custom highlight groups (Catppuccin Mocha)
    vim.api.nvim_set_hl(0, 'MiniStatuslineMacro', { fg = '#fab387', bg = '#313244', bold = true })
    vim.api.nvim_set_hl(0, 'MiniStatuslineSearch', { fg = '#1e1e2e', bg = '#fab387' })
    vim.api.nvim_set_hl(0, 'MiniStatuslineShowcmd', { fg = '#cba6f7', bg = '#313244' })

    local function section_macro()
      local reg = vim.fn.reg_recording()
      return reg ~= '' and ('@' .. reg) or ''
    end

    local function section_search()
      if vim.v.hlsearch ~= 1 then
        return ''
      end
      local s = vim.fn.searchcount({ maxcount = 0 })
      if s.total == 0 then
        return ''
      end
      return ('[%d/%d]'):format(s.current, s.total)
    end

    statusline.active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 20000 })
      local git = statusline.section_git({ trunc_width = 40 })
      local filename = statusline.section_filename({ trunc_width = 20000 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 20000 })
      local location = statusline.section_location()
      local showcmd = vim.api.nvim_eval_statusline('%S', {}).str

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git } },
        { hl = 'MiniStatuslineMacro', strings = { section_macro() } },
        '%<', -- Mark general truncate point
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = 'MiniStatuslineShowcmd', strings = { showcmd } },
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = 'MiniStatuslineSearch', strings = { section_search() } },
        { hl = mode_hl, strings = { location } },
      })
    end

    statusline.section_location = function()
      return '%2l:%-2v'
    end

    -- Mini.pairs for auto-pairing brackets
    require('mini.pairs').setup()

    -- Mini.icons
    require('mini.icons').setup()

    -- Mini.ai for better text objects
    require('mini.ai').setup({ n_lines = 500 })

    -- Mini.surround for surround operations
    require('mini.surround').setup()

    -- Mini.animate for animating movements
    require('mini.animate').setup()
  end,
}
