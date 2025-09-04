_: {
  programs.nvf.settings.vim.lsp = {
    formatOnSave = true;
    lspkind.enable = true;
    lightbulb.enable = true;
    lspsaga.enable = true;
    trouble.enable = true;
    lspSignature.enable = false;
    nvim-docs-view.enable = true;
    # lsp features and a code completion source for code embedded in other documents
    otter-nvim.enable = false; 
    mappings = {
      renameSymbol = "<leader>rn";
      openDiagnosticFloat  = "<leader>e";
      hover = "K";
      goToDeclaration  = "gD";
      codeAction = "<leader>ca";
    };
  };
}
