-- =============================================================================
-- FORMAT DISPATCHER
-- Reads Nix-provided formatter metadata (fast/slow per filetype) and provides:
--   M.format_fast(bufnr)        — sync, used in format_on_save (BufWritePre)
--   M.format_after_save(bufnr)  — async after-save for filetypes that timed out
--   M.format_slow(bufnr)        — async background, notification on completion
--   M.format_all(bufnr)         — fast sync + slow async
--
-- Slow-filetype detection (from codehia/neovim):
--   On first timeout, the filetype is added to slow_format_filetypes.
--   format_fast skips it on subsequent saves; format_after_save handles it async.
-- =============================================================================

local M = {}

-- Filetypes that timed out on fast format — switched to after-save async
local slow_format_filetypes = {}

--- Get fast formatters for a filetype from Nix info
---@param ft string
---@return string[]|nil
function M.get_fast(ft)
  local list = nix_info('formatters', 'fast', ft)
  if type(list) == 'table' and #list > 0 then
    return list
  end
  return nil
end

--- Get slow formatters for a filetype from Nix info
---@param ft string
---@return string[]|nil
function M.get_slow(ft)
  local list = nix_info('formatters', 'slow', ft)
  if type(list) == 'table' and #list > 0 then
    return list
  end
  return nil
end

--- Run fast formatters synchronously (for BufWritePre).
--- If a filetype is already marked slow, skips — format_after_save handles it.
--- On timeout, marks the filetype as slow for future saves.
---@param bufnr number
function M.format_fast(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  -- Already known to be slow — defer to format_after_save
  if slow_format_filetypes[ft] then
    return
  end

  local fast = M.get_fast(ft)
  if fast then
    require('conform').format({
      bufnr = bufnr,
      formatters = fast,
      timeout_ms = 500,
      lsp_format = 'fallback',
    }, function(err)
      if err and err:match('timeout$') then
        slow_format_filetypes[ft] = true
      end
    end)
  else
    -- No Nix-declared fast formatters — fall back to LSP
    require('conform').format({
      bufnr = bufnr,
      timeout_ms = 500,
      lsp_format = 'fallback',
    })
  end
end

--- After-save handler for slow filetypes (return value used by conform's format_after_save).
--- Returns conform options if: ft was promoted to slow (timeout), OR ft has slow formatters but no fast ones.
---@param bufnr number
---@return table|nil
function M.format_after_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  if slow_format_filetypes[ft] or (M.get_slow(ft) and not M.get_fast(ft)) then
    return { async = true, lsp_format = 'fallback' }
  end
  return nil
end

--- Run slow formatters asynchronously (background, notifies on completion).
--- Used for manual invocation via <leader>cF.
---@param bufnr? number
function M.format_slow(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local slow = M.get_slow(ft)

  if not slow then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local short = vim.fn.fnamemodify(bufname, ':t')

  require('conform').format({
    bufnr = bufnr,
    formatters = slow,
    async = true,
    lsp_format = 'never',
  }, function(err)
    if err then
      vim.notify('Slow format failed: ' .. err, vim.log.levels.WARN)
    else
      vim.notify('Slow format done: ' .. short, vim.log.levels.INFO)
    end
  end)
end

--- Run fast (sync) then slow (async) formatters
---@param bufnr? number
function M.format_all(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.format_fast(bufnr)
  M.format_slow(bufnr)
end

return M
