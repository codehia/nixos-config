# Changes Summary (dendritic branch)

Apply these on the thinkpad to bring it up to date.

## 1. Deleted old layout leftovers

These dirs are from the pre-dendritic layout and are completely unused:

```bash
rm -rf nixos/ home/
```

Deleted files:
- `nixos/configuration.nix`, `nixos/fonts.nix`
- `home/default.nix`, `home/git.nix`, `home/lazygit.nix`, `home/rofi.nix`
- `home/hyprland/{default,binds,hyprland}.nix`
- `home/nvf/{default,commands,keymaps,nvf,telescope}.nix`

## 2. Disko aspect refactoring

**`modules/disko.nix`** — Added `den.aspects.disko` with the NixOS module import:
```nix
{ inputs, ... }:
{
  flake-file.inputs.disko = { ... };

  den.aspects.disko = {
    nixos = { ... }: {
      imports = [ inputs.disko.nixosModules.disko ];
    };
  };
}
```

**`modules/thinkpad/thinkpad.nix`** — Removed `inputs.disko.nixosModules.disko` from nixos imports, removed `inputs` from function args (now `{ den, ... }:`), added `den.aspects.disko` to includes list.

## 3. Apple-fonts aspect refactoring

**Created `modules/apple-fonts.nix`** — Extracted apple-fonts into its own aspect:
```nix
{ inputs, ... }:
{
  flake-file.inputs.apple-fonts = {
    url = "github:Lyndeno/apple-fonts.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.apple-fonts = {
    nixos = { pkgs, ... }: {
      fonts.packages = with inputs.apple-fonts.packages.${pkgs.system}; [
        sf-pro sf-mono ny
      ];
    };
  };
}
```

**`modules/fonts.nix`** — Removed `flake-file.inputs.apple-fonts` and direct `inputs` usage. Now uses `{ den, ... }:` and includes the apple-fonts aspect:
```nix
den.aspects.fonts = {
  nixos = { pkgs, ... }: {
    fonts.packages = with pkgs; [ ... ];  # no more apple-fonts here
  };
  includes = [ den.aspects.apple-fonts ];
};
```

## 4. Apple-fonts upstream status

As of 2026-02-13, the hash mismatch issue is **fixed upstream**. All three packages (sf-pro, sf-mono, ny) build successfully:
```bash
nix build "github:Lyndeno/apple-fonts.nix#sf-pro"
nix build "github:Lyndeno/apple-fonts.nix#sf-mono"
nix build "github:Lyndeno/apple-fonts.nix#ny"
```

## Verification

```bash
nix-instantiate --parse modules/disko.nix
nix-instantiate --parse modules/apple-fonts.nix
nix-instantiate --parse modules/fonts.nix
nix-instantiate --parse modules/thinkpad/thinkpad.nix
nix flake check
just install
```
