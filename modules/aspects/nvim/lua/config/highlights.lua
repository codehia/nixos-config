-- =============================================================================
-- PER-LANGUAGE SYNTAX HIGHLIGHTS
-- Neovim resolves @capture.lang before @capture, so languages listed here get
-- targeted tweaks while everything else keeps the colorscheme defaults.
--
-- No colors are hardcoded: `base` names an existing semantic group. Entries
-- with only `base` become pure links (the theme supplies the color); entries
-- with style flags resolve the base group's current colors at runtime and
-- overlay just the flags. Theme-agnostic — re-applied on ColorScheme.
-- Use :Inspect on a token to see its captures when tuning.
-- =============================================================================

local per_lang = {
  nix = {
    -- attr keys (services.nginx.enable) take the label color instead of
    -- blending into the same teal as every member/property
    ['@variable.member'] = { base = '@label' },
    -- ./paths: keep the special-string color, set apart from strings by slant
    ['@string.special.path'] = { base = '@string.special', italic = true },
  },
  python = {
    -- docstrings are documentation, not yellow string literals
    ['@string.documentation'] = { base = '@comment.documentation' },
    ['@attribute'] = { base = '@attribute', italic = true }, -- decorators
  },
  typescript = {
    -- primitive types (string/number/any) vs user-defined types
    ['@type.builtin'] = { base = '@type.builtin', italic = true },
  },
  tsx = {
    ['@type.builtin'] = { base = '@type.builtin', italic = true },
    -- de-emphasize <> so tag content pops
    ['@tag.delimiter'] = { base = '@comment', italic = false },
  },
  go = {
    ['@type.builtin'] = { base = '@type.builtin', italic = true },
  },
  rust = {
    ['@attribute'] = { base = '@attribute', italic = true }, -- #[derive(...)]
    ['@type.builtin'] = { base = '@type.builtin', italic = true },
  },
  bash = {
    -- $VARS read as parameters, standing out against strings and commands
    ['@variable'] = { base = '@variable.parameter' },
  },
  fish = {
    ['@variable'] = { base = '@variable.parameter' },
  },
  html = {
    ['@tag.attribute'] = { base = '@attribute', italic = true },
    ['@tag.delimiter'] = { base = '@comment', italic = false },
  },
  css = {
    -- property names are the attributes of a rule
    ['@property'] = { base = '@attribute' },
  },
}

local function apply()
  for lang, groups in pairs(per_lang) do
    for capture, spec in pairs(groups) do
      local name = capture .. '.' .. lang
      if vim.tbl_count(spec) == 1 then
        vim.api.nvim_set_hl(0, name, { link = spec.base })
      else
        local merged = vim.tbl_extend('force', vim.api.nvim_get_hl(0, { name = spec.base, link = false }), spec)
        merged.base = nil
        vim.api.nvim_set_hl(0, name, merged)
      end
    end
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('per-lang-highlights', { clear = true }),
  callback = apply,
})

-- The colorscheme loads after config modules (via lze), so the autocmd
-- catches it; apply directly in case one is already active.
if vim.g.colors_name then
  apply()
end
