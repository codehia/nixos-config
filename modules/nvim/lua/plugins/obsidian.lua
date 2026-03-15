-- =============================================================================
-- OBSIDIAN — Markdown note-taking linked to Obsidian vault
-- =============================================================================

return {
  -- ---------------------------------------------------------------------------
  -- obsidian.nvim — Obsidian vault integration
  -- pname: obsidian.nvim
  -- Lazy-loads on markdown filetypes, :Obsidian command, or keybindings
  -- ---------------------------------------------------------------------------
  {
    'obsidian.nvim',
    ft = { 'markdown' },
    cmd = { 'Obsidian' },
    keys = {
      { '<leader>on', '<cmd>Obsidian new<cr>', desc = '[O]bsidian [N]ew note' },
      { '<leader>oN', '<cmd>Obsidian new_from_template<cr>', desc = '[O]bsidian [N]ew from template' },
      { '<leader>oo', '<cmd>Obsidian open<cr>', desc = '[O]bsidian [O]pen note' },
      { '<leader>os', '<cmd>Obsidian search<cr>', desc = '[O]bsidian [S]earch' },
      { '<leader>ob', '<cmd>Obsidian backlinks<cr>', desc = '[O]bsidian [B]acklinks' },
      { '<leader>ot', '<cmd>Obsidian tags<cr>', desc = '[O]bsidian [T]ags' },
      { '<leader>od', '<cmd>Obsidian today<cr>', desc = '[O]bsidian [D]aily note' },
      { '<leader>oy', '<cmd>Obsidian yesterday<cr>', desc = '[O]bsidian [Y]esterday' },
      { '<leader>ol', '<cmd>Obsidian link<cr>', desc = '[O]bsidian [L]ink to note' },
      { '<leader>ow', '<cmd>Obsidian workspace<cr>', desc = '[O]bsidian [W]orkspace' },
    },
    after = function()
      require('obsidian').setup({
        workspaces = {
          {
            name = 'personal',
            path = '/home/deus/workspace/personal/vault',
          },
        },

        picker = { name = 'telescope' },

        daily_notes = {
          folder = 'daily',
          date_format = '%Y-%m-%d',
        },

        frontmatter = { enabled = true },
        legacy_commands = false,

        note_id_func = function(title)
          return title or tostring(os.time())
        end,

        follow_url_func = function(url)
          vim.fn.jobstart({ 'xdg-open', url })
        end,
      })
    end,
  },

  { 'plenary.nvim', dep_of = { 'obsidian.nvim' } },
}
