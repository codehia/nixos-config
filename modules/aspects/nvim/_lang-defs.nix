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
      djlint
      yamllint
      actionlint
    ];
    formatters = {
      fast = {
        sh = [ "shfmt" ];
        markdown = [ "markdownlint" ];
        htmldjango = [ "djlint" ];
      };
      slow = { };
    };
    linters = {
      htmldjango = [ "djlint" ];
      sh = [ "shellcheck" ];
      bash = [ "shellcheck" ];
      fish = [ "fish" ];
      # config-gated in coding.lua: silent unless the repo has a config
      markdown = [ "markdownlint" ];
      yaml = [
        "yamllint" # config-gated
        "actionlint" # path-gated: .github/workflows only
      ];
    };
  };

  lua = {
    packages = with pkgs; [
      lua-language-server
      stylua
      selene
      luajitPackages.luacheck
    ];
    formatters = {
      fast = {
        lua = [ "stylua" ];
      };
      slow = { };
    };
    linters = {
      # both config-gated in coding.lua; first with a config wins
      lua = [
        "selene"
        "luacheck"
      ];
    };
  };

  nix = {
    packages = with pkgs; [
      nixd
      nixfmt
      statix
      deadnix
    ];
    formatters = {
      fast = {
        nix = [ "nixfmt" ];
      };
      slow = { };
    };
    linters = {
      nix = [
        "statix"
        "deadnix"
      ];
    };
  };

  python = {
    packages = with pkgs; [
      basedpyright
      ruff
    ];
    formatters = {
      fast = {
        python = [
          "ruff_organize_imports"
          "ruff_format"
        ];
      };
      slow = { };
    };
    linters = {
      python = [ "ruff" ];
    };
  };

  typescript = {
    packages = with pkgs; [
      typescript-language-server
      # 26.05 prettier builds with insecure pnpm_9; revert to `prettier` once the pnpm_10 bump is backported
      unstable.prettier
      eslint_d
      biome
    ];
    formatters = {
      fast = {
        javascript = [
          "biome"
          "prettier"
        ];
        typescript = [
          "biome"
          "prettier"
        ];
        javascriptreact = [
          "biome"
          "prettier"
        ];
        typescriptreact = [
          "biome"
          "prettier"
        ];
        json = [ "prettier" ];
        yaml = [ "prettier" ];
      };
      slow = { };
    };
    linters = {
      javascript = [
        "biomejs"
        "eslint"
      ];
      typescript = [
        "biomejs"
        "eslint"
      ];
      javascriptreact = [
        "biomejs"
        "eslint"
      ];
      typescriptreact = [
        "biomejs"
        "eslint"
      ];
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

  astro = {
    packages = with pkgs; [
      astro-language-server
    ];
    formatters = {
      fast = {
        astro = [
          "biome"
          "prettier"
        ];
      };
      slow = { };
    };
    linters = { };
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
