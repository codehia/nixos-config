# Per-language definitions: packages, formatters (fast/slow), and linters.
# Consumed by nvim.nix to compose extraPackages and expose metadata to Lua.
{ pkgs }:
{
  general = {
    packages = with pkgs; [
      lazygit
      git
      ripgrep
      fd
      fzf
      fortune
      cowsay
      universal-ctags
      gnumake
      gcc
      gh
      shfmt
      shellcheck
      markdownlint-cli
    ];
    formatters = {
      fast = {
        sh = [ "shfmt" ];
        markdown = [ "markdownlint" ];
      };
      slow = { };
    };
    linters = { };
  };

  lua = {
    packages = with pkgs; [
      lua-language-server
      stylua
    ];
    formatters = {
      fast = {
        lua = [ "stylua" ];
      };
      slow = { };
    };
    linters = { };
  };

  nix = {
    packages = with pkgs; [
      nixd
      alejandra
    ];
    formatters = {
      fast = {
        nix = [ "alejandra" ];
      };
      slow = { };
    };
    linters = { };
  };

  python = {
    packages = with pkgs; [
      basedpyright
      python3Packages.flake8
      python3Packages.autopep8
      isort
    ];
    formatters = {
      fast = {
        python = [ ];
      };
      slow = {
        python = [
          "isort"
          "autopep8"
        ];
      };
    };
    linters = {
      python = [ "flake8" ];
    };
  };

  typescript = {
    packages = with pkgs; [
      typescript-language-server
      nodePackages.prettier
      eslint_d
    ];
    formatters = {
      fast = { };
      slow = {
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        typescriptreact = [ "prettier" ];
        json = [ "prettier" ];
        yaml = [ "prettier" ];
      };
    };
    linters = {
      javascript = [ "eslint" ];
      typescript = [ "eslint" ];
      javascriptreact = [ "eslint" ];
      typescriptreact = [ "eslint" ];
    };
  };

  go = {
    packages = with pkgs; [
      gopls
      delve
      golangci-lint
      go
    ];
    formatters = {
      fast = {
        go = [ "gofumpt" ];
      };
      slow = { };
    };
    linters = {
      go = [ "golangcilint" ];
    };
  };

  rust = {
    packages = with pkgs; [
      rust-analyzer
      rustfmt
      clippy
    ];
    formatters = {
      fast = {
        rust = [ "rustfmt" ];
      };
      slow = { };
    };
    linters = {
      rust = [ "clippy" ];
    };
  };

  latex = {
    packages = with pkgs; [
      texlab
      latexrun
      biber
    ];
    formatters = {
      fast = {
        tex = [ "latexindent" ];
        bib = [ "bibtex-tidy" ];
      };
      slow = { };
    };
    linters = {
      tex = [ "chktex" ];
    };
  };
}
