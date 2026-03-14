-- =============================================================================
-- UTIL PLUGINS
-- =============================================================================
return {
  {
    'hardtime.nvim',
    lazy = false,
    after = function()
      require('hardtime').setup({ enabled = false })
    end,
  },
}
