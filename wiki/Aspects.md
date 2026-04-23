# Aspects

## Adding a package

**User package** (goes in home-manager, only for that user):

```nix
# modules/aspects/packages.nix
den.aspects.packages = {
  homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      btop
      unstable.some-new-app   # pkgs.unstable.* is always available via overlay
    ];
  };
};
```

**System package** (available for all users):

```nix
nixos = { pkgs, ... }: {
  environment.systemPackages = [ pkgs.htop ];
};
```

For host-specific packages, put it directly in the host's `nixos` block in
`modules/hosts/<hostname>/default.nix` instead of a shared aspect.

---

## Adding a new aspect

An aspect is just a `.nix` file. It can have a `nixos` block (system config), a
`homeManager` block (user config), or both. Den routes them to the right place.

**Step 1 — create the file:**

```nix
# modules/aspects/myapp.nix
{ den, ... }:
{
  den.aspects.myapp = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.myapp ];
      programs.myapp = {
        enable = true;
        settings.theme = "dark";
      };
    };
  };
}
```

**Step 2 — stage it:**

```bash
git add modules/aspects/myapp.nix
```

import-tree discovers files through git, so it won't exist to the build until staged.

**Step 3 — include it:**

For a user feature, add it to the user aspect's `includes`:

```nix
# modules/users/deus.nix
den.aspects.deus = {
  includes = [
    ...
    den.aspects.myapp
  ];
};
```

For a system feature, add it to the host's `includes`:

```nix
# modules/hosts/personal/default.nix
den.aspects.personal = {
  includes = [
    ...
    den.aspects.myapp
  ];
};
```

---

## System config + user config in the same aspect

Both `nixos` and `homeManager` blocks can live in the same aspect:

```nix
{ den, ... }:
{
  den.aspects.myapp = {
    nixos.services.myapp.enable = true;       # goes to NixOS system config
    homeManager.programs.myapp.enable = true; # goes to each user's home-manager
  };
}
```

---

## Config that differs per host

Use `den.lib.perHost` with a named function:

```nix
{ den, ... }:
let
  gpuConfig = { host, ... }:
    let gpuKey = host.gpuKey or null;
    in {
      nixos = { lib, ... }: lib.optionalAttrs (gpuKey != null) {
        services.lact.settings.gpus.${gpuKey}.fan_control_enabled = true;
      };
    };
in
{
  den.aspects.lact = {
    nixos.services.lact.enable = true;
    includes = [ (den.lib.perHost gpuConfig) ];
  };
}
```

Always give the function a name. Never write `includes = [ (den.lib.perHost ({ host, ... }: { ... })) ]`
— the anonymous form makes traces impossible to read.

---

## Aspect that only runs on specific hosts (for deus)

`deus.nix` has an `extraAspectsSelector` that reads `host.extraAspects`. Add the aspect
name to the host's declaration and deus gets it only there:

```nix
# modules/hosts/thinkpad/default.nix
den.hosts.x86_64-linux.thinkpad = {
  extraAspects = [
    "rclone"     # deus gets rclone on thinkpad only
  ];
};
```

---

## Split an aspect across multiple files (collector pattern)

Multiple files can define the same aspect name — den merges them:

```nix
# modules/aspects/myapp/myapp.nix
den.aspects.myapp = {
  nixos.programs.myapp.enable = true;
};

# modules/aspects/myapp/myapp-keybinds.nix
den.aspects.myapp = {
  homeManager.programs.myapp.keybinds = { ... };
};
```

Stage both, include `den.aspects.myapp` once — both files contribute automatically.
