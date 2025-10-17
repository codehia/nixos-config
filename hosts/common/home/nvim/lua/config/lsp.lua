-- =============================================================================
-- LSP CONFIGURATION
-- =============================================================================

local M = {}

-- LSP on_attach function for keymaps
M.lsp_on_attach = function(client, bufnr)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  -- Use Telescope for LSP navigation if available, otherwise use built-in
  local has_telescope, telescope = pcall(require, 'telescope.builtin')
  
  if has_telescope then
    -- Jump to the definition of the word under your cursor
    map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')

    -- Find references for the word under your cursor
    map('gr', telescope.lsp_references, '[G]oto [R]eferences')

    -- Jump to the implementation of the word under your cursor
    map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')

    -- Jump to the type of the word under your cursor
    map('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')

    -- Fuzzy find all the symbols in your current document
    map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')

    -- Fuzzy find all the symbols in your current workspace
    map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  else
    -- Fallback to built-in LSP functions
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
    map('<leader>ws', vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols')
  end

  -- Rename the variable under your cursor
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

  -- Execute a code action
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

  -- Opens a popup that displays documentation about the word under your cursor
  map('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Toggle inlay hints
  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
    end, '[T]oggle Inlay [H]ints')
  end
end

-- Setup LSP servers
M.setup = function()
  local lspconfig = require('lspconfig')

  -- Lua LSP
  if nixCats('lua') then
    lspconfig.lua_ls.setup({
      on_attach = M.lsp_on_attach,
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          workspace = {
            checkThirdParty = false,
            library = {
              '${3rd}/luv/library',
              unpack(vim.api.nvim_get_runtime_file('', true)),
            },
          },
          completion = {
            callSnippet = 'Replace',
          },
          diagnostics = { disable = { 'missing-fields' } },
        },
      },
    })
  end

  -- Nix LSP
  if nixCats('nix') then
    lspconfig.nixd.setup({
      on_attach = M.lsp_on_attach,
    })
  end

  -- Python LSP
  if nixCats('python') then
    lspconfig.basedpyright.setup({
      cmd = { 'basedpyright-langserver', '--stdio' },
      filetypes = { 'python' },
      root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
        '.git',
      },
      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = 'openFilesOnly',
          },
        },
      },
      on_attach = function(client, bufnr)
        M.lsp_on_attach(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
          client:exec_cmd({
            command = 'basedpyright.organizeimports',
            arguments = { vim.uri_from_bufnr(bufnr) },
          })
        end, {
          desc = 'Organize Imports',
        })
      end,
    })
  end

  -- TypeScript LSP
  if nixCats('typescript') then
    lspconfig.ts_ls.setup({
      on_attach = M.lsp_on_attach,
    })
  end

  -- Go LSP
  if nixCats('go') then
    lspconfig.gopls.setup({
      on_attach = M.lsp_on_attach,
    })
  end
end

return M
