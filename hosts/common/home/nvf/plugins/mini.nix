{ pkgs, lib, ... }:

let luaInlineFunction = luaFunction: lib.generators.mkLuaInline luaFunction;
in {
  programs.nvf.settings.vim.mini = {
    animate.enable = true;
    ai = {
      enable = true;
      setupOpts = { n_lines = 500; };
    };
    # TODO: Check how to enable treesitter config
    surround = { enable = true; };
    starter = {
      enable = true;
      setupOpts = {
        header = luaInlineFunction ''
          function()
            local handle = assert(io.popen('fortune -s | cowsay', 'r'))
            local output = handle:read '*all'
            handle:close()
            return output
          end'';
        items = luaInlineFunction ''
          {
            require("mini.starter").sections.recent_files(5, true, false),
            require("mini.starter").sections.builtin_actions(),
          }'';
        content_hooks = luaInlineFunction ''
          {
            require("mini.starter").gen_hook.adding_bullet(),
            require("mini.starter").gen_hook.aligning('center', 'center'),
            require("mini.starter").gen_hook.indexing('all', { 'Builtin actions' }),
            require("mini.starter").gen_hook.padding(3, 2),
          }'';
        footer = "";
      };
    };
    statusline = {
      enable = true;
      setupOpts.content = {
        active = luaInlineFunction ''
          function()
            local statusline = require("mini.statusline")

            local mode, mode_hl = statusline.section_mode { trunc_width = 20000 }
            local git = statusline.section_git { trunc_width = 40 }
            local filename = statusline.section_filename { trunc_width = 20000 }
            local fileinfo = statusline.section_fileinfo { trunc_width = 20000 }
            local location = function() return '%2l:%-2v' end
            local diff = statusline.section_diff({trunc_width = 55})
            local diagnostics = statusline.section_diagnostics({trunc_width = 55})
            local search = statusline.section_searchcount({trunc_width = 55})

            local has_diagnostics = diagnostics and diagnostics ~= ""
            local git_hl= has_diagnostics and "MiniStatuslineInfoBg2" or "MiniStatuslineInfoBg1"

            return statusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git } },
              '%<', -- Mark general truncate point
              {hl = "MiniStatusLineInfoBg0"},
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              {hl = "MiniStatuslineInfoBg1", strings = {diagnostics}},
              {hl = git_hl, strings = {git}},
              {hl = git_hl, strings = {diff}},
              { hl = mode_hl, strings = { location } },
            })
          end
        '';
      };
    };
  };
}
