-- =============================================================================
-- FORMAT DISPATCHER
-- Reads Nix-provided formatter metadata (fast/slow per filetype) and provides:
--   M.format_fast(bufnr)  — sync, used in BufWritePre
--   M.format_slow(bufnr)  — async background, notification on completion
--   M.format_all(bufnr)   — fast sync + slow async
-- =============================================================================

local M = {}

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

--- Run fast formatters synchronously (for BufWritePre)
---@param bufnr number
function M.format_fast(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local fast = M.get_fast(ft)

  if fast then
    require('conform').format({
      bufnr = bufnr,
      formatters = fast,
      timeout_ms = 500,
      lsp_format = 'fallback',
    }, function(err)
      -- If fast formatting timed out or failed, queue slow formatters
      if err then
        vim.schedule(function()
          M.format_slow(bufnr)
        end)
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

--- Run slow formatters asynchronously (background, notifies on completion)
---@param bufnr number
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
---@param bufnr number
function M.format_all(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.format_fast(bufnr)
  M.format_slow(bufnr)
end

return M
