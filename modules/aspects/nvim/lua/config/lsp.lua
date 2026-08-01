-- =============================================================================
-- LSP CONFIGURATION
-- =============================================================================

local M = {}

-- LSP on_attach — keymaps, inlay hints, navic, document highlights
M.on_attach = function(client, bufnr)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  -- Use Telescope for LSP navigation if available, otherwise use built-in
  local has_telescope, telescope = pcall(require, 'telescope.builtin')

  if has_telescope then
    map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
    map('gr', telescope.lsp_references, '[G]oto [R]eferences')
    map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  else
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
    map('<leader>ws', vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols')
  end

  map('K', function()
    vim.lsp.buf.hover({ border = 'rounded' })
  end, 'Hover Documentation')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'v' })
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('gK', function()
    vim.lsp.buf.signature_help({ border = 'rounded' })
  end, 'Signature Documentation')
  map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  map('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Toggle inlay hints
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
    end, '[T]oggle Inlay [H]ints')
  end

  -- Document highlight on cursor hold
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
    local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight-' .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = bufnr,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      buffer = bufnr,
      group = highlight_augroup,
      callback = function()
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = highlight_augroup })
      end,
    })
  end

  -- Attach navic for breadcrumbs
  local has_navic, navic = pcall(require, 'nvim-navic')
  if has_navic and client and client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  -- Format command
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Native Neovim 0.12 LSP setup
M.setup = function()
  vim.lsp.config('*', { on_attach = M.on_attach })

  vim.diagnostic.config({
    float = { border = 'rounded', source = true },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '✘',
        [vim.diagnostic.severity.WARN] = '▲',
        [vim.diagnostic.severity.INFO] = '⚑',
        [vim.diagnostic.severity.HINT] = '»',
      },
    },
  })

  vim.lsp.config('lua_ls', {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        formatters = { ignoreComments = true },
        signatureHelp = { enabled = true },
        diagnostics = { globals = { 'vim' }, disable = { 'missing-fields' } },
        telemetry = { enabled = false },
      },
    },
  })

  vim.lsp.config('nixd', {
    cmd = { 'nixd' },
    filetypes = { 'nix' },
    root_markers = { 'flake.nix', '.git' },
    settings = {
      nixd = {
        nixpkgs = { expr = nix_info('nixdExtras', 'nixpkgs') or 'import <nixpkgs> {}' },
        formatting = { command = { 'nixfmt' } },
        diagnostic = { suppress = { 'sema-escaping-with' } },
      },
    },
  })

  vim.lsp.config('basedpyright', {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
    settings = {
      basedpyright = {
        analysis = {
          typeCheckingMode = 'basic',
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  })

  vim.lsp.config('ts_ls', {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  })

  vim.lsp.config('astro', {
    cmd = { 'astro-ls', '--stdio' },
    filetypes = { 'astro' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    init_options = { typescript = {} },
  })

  vim.lsp.config('gopls', {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.mod', 'go.work', '.git' },
  })

  vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = { command = 'clippy' },
      },
    },
  })

  vim.lsp.config('texlab', {
    cmd = { 'texlab' },
    filetypes = { 'tex', 'plaintex', 'bib' },
    root_markers = { '.latexmkrc', '.texlabroot', 'texlabroot', 'Tectonic.toml', '.git' },
    settings = {
      texlab = {
        build = {
          executable = 'latexrun',
          args = { '%f' },
          onSave = false,
          forwardSearchAfter = false,
        },
        chktex = { onOpenAndSave = true, onEdit = false },
      },
    },
  })

  vim.lsp.enable({
    'lua_ls',
    'nixd',
    'basedpyright',
    'ts_ls',
    'astro',
    'gopls',
    'rust_analyzer',
    'texlab',
  })
end

return M
