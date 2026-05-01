-- ---------------------------------------------------------------------------
-- Mini — starter, statusline, pairs, icons, ai, surround
-- ---------------------------------------------------------------------------
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
    local statusline = require('mini.statusline')
    statusline.setup({ use_icons = vim.g.have_nerd_font })
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 20000 })
      local git = statusline.section_git({ trunc_width = 40 })
      local filename = statusline.section_filename({ trunc_width = 20000 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 20000 })
      local location = statusline.section_location()
      -- Check why the LSP is showing ++ and add to fileinfo
      -- local lsp = statusline.section_lsp { trunc_width = 20, icon = '󰿘 ' }

      local macro_reg = vim.fn.reg_recording()
      local macro = macro_reg ~= '' and ('  @' .. macro_reg) or ''

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode, macro } },
        { hl = 'MiniStatuslineDevinfo', strings = { git } },
        '%<', -- Mark general truncate point
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      })
    end
    statusline.section_location = function()
      local search = ''
      if vim.v.hlsearch == 1 then
        local s = vim.fn.searchcount()
        if s.total > 0 then
          search = (' [%d/%d]'):format(s.current, s.total)
        end
      end
      return '%2l:%-2v' .. search
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
