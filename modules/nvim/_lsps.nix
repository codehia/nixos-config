{ pkgs }:
with pkgs;
[
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
  lua-language-server
  stylua
  nixd
  alejandra
  basedpyright
  python3Packages.flake8
  ruff
  python3Packages.autopep8
  black
  isort
  typescript-language-server
  nodePackages.prettier
  eslint_d
  shfmt
  shellcheck
  markdownlint-cli # new for conform/lint
  gopls
  delve
  golangci-lint
  go # go tools (gated by nix_has_feature in Lua)
  gh # for octo.nvim (also via shell-tools/gh.nix)
]
