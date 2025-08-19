{ lib, ... }:
let luaInlineFunction = luaFunction: lib.generators.mkLuaInline luaFunction;
in {
  programs.nvf.settings.vim = {
    augroups = [{ name = "_nvf"; }];
    autocmds = [
      {
        enable = true;
        desc = "Highlight when yanking (copying) text";
        event = [ "TextYankPost" ];
        group = "_nvf";
        callback = luaInlineFunction ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }
      {
        enable = true;
        desc = "Check if we need to reload the file when it changes";
        event = [ "FocusGained" "TermClose" "TermLeave" ];
        group = "_nvf";
        callback = luaInlineFunction ''
          function ()
            if vim.o.buftype ~= 'nofile' then
              vim.cmd 'checktime'
            end
          end
        '';
      }
      {
        enable = true;
        desc = "Resize splits if window got resized";
        event = [ "VimResized" ];
        group = "_nvf";
        callback = luaInlineFunction ''
          function()
            local current_tab = vim.fn.tabpagenr()

            vim.cmd 'tabdo wincmd ='
            vim.cmd('tabnext' .. current_tab)
          end
        '';
      }
      {
        enable = true;
        desc = "Allow some special buffers/filetypes by q";
        event = [ "FileType" ];
        group = "_nvf";
        pattern = [
          "PlenaryTestPopup"
          "help"
          "spinfo"
          "notify"
          "qf"
          "spectre_panel"
          "startuptime"
          "tsplayground"
          "neotest-output"
          "checkhealth"
          "neotest-summary"
          "neotest-output-panel"
          "dbout"
          "oil"
        ];
        callback = luaInlineFunction ''
          function (event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
          end
        '';
      }
      {
        enable = true;
        desc = "Resize splits if window got resized";
        event = [ "VimResized" ];
        group = "_nvf";
        callback = luaInlineFunction ''
          function()
            local current_tab = vim.fn.tabpagenr()

            vim.cmd 'tabdo wincmd ='
            vim.cmd('tabnext' .. current_tab)
          end
        '';
      }
      {
        enable = true;
        desc = "Auto-update programming wordlist on first startup";
        event = [ "VimEnter" ];
        group = "_nvf";
        callback = luaInlineFunction ''
          function()
              -- Check if dirtytalk dict file exists
              local dict_path = vim.fn.stdpath('data') .. '/site/spell/programming.utf-8.add'
              if vim.fn.filereadable(dict_path) == 0 then
                -- Only run if file doesn't exist to avoid repeated downloads
                vim.schedule(function()
                   vim.cmd('DirtytalkUpdate')
                  end)
              end
            end
        '';
      }
    ];
  };
}
