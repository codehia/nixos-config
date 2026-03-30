# NixOS Config

Multi-machine NixOS config using the dendritic pattern — features are defined once and
composed into hosts/users. No repeating the same thing per machine.

**Machines:** `personal` (desktop, AMD GPU, swayfx), `thinkpad` (laptop, swayfx + hyprland),
`workstation` (shared desktop, hyprland)

**Users:** `deus` (primary on personal/thinkpad), `soumya` (primary on workstation, secondary
on thinkpad)

---

## Commands

```bash
just install         # build and apply — also auto-restores the sops age key if missing
just test            # activate temporarily, no boot entry
just dry             # preview what would change, nothing applied
just debug           # apply with full trace (good for debugging build failures)
just up              # update all flake inputs and rebuild
just upp i=NAME      # update one input, e.g. just upp i=home-manager
just clean           # garbage collect old generations
just write-flake     # regenerate flake.nix after adding/removing flake inputs
just history         # list past generations
```

> Never use `nix eval` or `nix repl` directly — causes a RAM spike. Use `just dry` instead.

---

## How it works

The whole thing is built around **aspects** — each aspect is a `.nix` file that owns one
feature. Hosts and users list which aspects they want in their `includes`. That's it.

```
fish.nix   git.nix   catppuccin.nix   nvim/   hyprland/   rclone.nix   ...
                                ↓
  personal: includes fish, git, catppuccin, nvim, swayfx, rclone, ...
  thinkpad: includes the same + hyprland in extraAspects
  workstation: soumya gets fish, git, catppuccin, nvim, hyprland, ...
```

The framework that wires this together is [den](https://github.com/vic/den). It runs a pipeline:

1. Each host gets a context → the host aspect applies (all `nixos.*` config goes here)
2. Each user declared on that host gets their own context → the user aspect applies
3. All `homeManager.*` config from any included aspect flows to that user's home-manager
4. `nixos.*` config from user aspects also flows up to the system (via `mutual-provider`)

**Auto-discovery:** All `.nix` files under `modules/` are picked up automatically via git
(using `import-tree`). Files or folders prefixed with `_` are excluded. After creating a
new `.nix` file, `git add` it before building — otherwise the build won't see it.

**`flake.nix` is auto-generated.** Each module declares its own flake inputs with
`flake-file.inputs`. After adding or removing any of those, run `just write-flake`.

---

## Folder structure

```
nixos-config/
├── flake.nix               # auto-generated, never edit by hand
├── Justfile                # all the just commands
├── .sops.yaml              # which age keys can decrypt which secrets files
│
├── secrets/                # sops-encrypted files
│   ├── deus.yaml           # deus's SSH private key (accessible on all 3 hosts)
│   ├── workstation.yaml    # SSH host key for workstation
│   ├── rclone.yaml         # rclone.conf (personal + thinkpad only)
│   └── ...
│
├── assets/.wallpapers/     # synced to ~/Pictures/Wallpapers on activation
├── notes/                  # reference docs (see table at end of this file)
│
└── modules/
    ├── den.nix             # bootstraps den + flake-file + import-tree
    ├── defaults.nix        # applied to every host and user
    ├── schema.nix          # unstable overlay, activates home-manager globally
    │
    ├── hosts/
    │   ├── personal/default.nix       # host declaration + personal aspect
    │   ├── thinkpad/default.nix       # host declaration + thinkpad aspect
    │   └── workstation/default.nix
    │
    ├── users/
    │   ├── deus.nix        # deus's feature includes, WM selector, identity
    │   └── soumya.nix      # soumya's feature includes, identity
    │
    └── aspects/
        ├── fish.nix
        ├── git.nix
        ├── ssh.nix
        ├── rclone.nix
        ├── nvim/           # split across multiple files (collector pattern)
        ├── hyprland/
        ├── swayfx/
        ├── system/         # system-level aspects (greetd, networking, ...)
        └── ...
```

---

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
    den.aspects.myapp   # add this line
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

### System config + user config in the same aspect

Both `nixos` and `homeManager` blocks can live in the same aspect. Den routes each to
the right place automatically:

```nix
{ den, ... }:
{
  den.aspects.myapp = {
    nixos.services.myapp.enable = true;       # goes to NixOS system config
    homeManager.programs.myapp.enable = true; # goes to each user's home-manager
  };
}
```

### Config that differs per host

Use `den.lib.perHost` with a named function. The function receives the host context and
returns config only for hosts where it makes sense.

Real example from `lact.nix` — GPU fan control only applies when a host has a `gpuKey`:

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

The key rule: **always give the function a name** (here `gpuConfig`). Never write
`includes = [ (den.lib.perHost ({ host, ... }: { ... })) ]` — the anonymous form
makes traces impossible to read.

Another common pattern — config that differs for laptop vs desktop:

```nix
let
  laptopConfig = { host, ... }:
    {
      nixos = { lib, ... }: lib.optionalAttrs (host.isLaptop or false) {
        services.tlp.enable = true;
      };
    };
in
den.aspects.power = {
  includes = [ (den.lib.perHost laptopConfig) ];
};
```

### Aspect that only runs on specific hosts (for deus)

`deus.nix` has an `extraAspectsSelector` that reads `host.extraAspects`. Add the aspect
name to the host's declaration and deus gets it only there:

```nix
# modules/hosts/thinkpad/default.nix
den.hosts.x86_64-linux.thinkpad = {
  extraAspects = [
    "hyprland"   # deus gets hyprland HM config on thinkpad only
    "rclone"     # deus gets rclone on thinkpad only
  ];
};
```

`soumya.nix` doesn't use this — soumya's includes are a fixed list.

### Split an aspect across multiple files

Multiple files can define the same aspect name — den merges them. This is called the
collector pattern and is how `hyprland/`, `nvim/`, `swayfx/` etc. work.

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

---

## Adding a new host

### 1. Create the files

```bash
mkdir -p modules/hosts/newhost
```

Files needed:
- `modules/hosts/newhost/default.nix` — tracked by git, contains the host declaration
- `modules/hosts/newhost/_hardware-configuration.nix` — generated by `nixos-generate-config`, `_`-prefixed so import-tree ignores it
- `modules/hosts/newhost/_disko-config.nix` — disk layout

### 2. Write `default.nix`

```nix
{ den, ... }:
{
  den.hosts.x86_64-linux.newhost = {
    home-manager.enable = true;
    wm = "swayfx";               # which WM deus uses on this host
    greetdUser = "deus";         # who gets auto-logged in at boot
    greetdSessionBin = "sway";   # session command for auto-login
    nhCleanEnabled = true;
    isLaptop = false;
    nvimLanguages = [ "lua" "nix" "python" ];
    users.deus = { };
  };

  den.aspects.newhost = {
    nixos = { ... }: {
      imports = [ ./_hardware-configuration.nix ./_disko-config.nix ];
      time.timeZone = "Asia/Kolkata";
      i18n.defaultLocale = "en_US.UTF-8";
    };

    includes = [
      den.aspects.nix-config
      den.aspects.networking
      den.aspects.boot
      den.aspects.sudo
      den.aspects.disko
      den.aspects.nh
      den.aspects.nix-tools
      den.aspects.tailscale
      den.aspects.pipewire
      den.aspects.graphics
      den.aspects.zram
      den.aspects.dms
      den.aspects.greetd
      den.aspects.fonts
      den.aspects.gnome-keyring
    ];
  };
}
```

### 3. Generate an age key on the new machine

```bash
# Run on the new machine:
sudo mkdir -p /var/lib/sops/age
sudo age-keygen -o /var/lib/sops/age/keys.txt
sudo chmod 600 /var/lib/sops/age/keys.txt

# Print the public key — needed for .sops.yaml:
sudo age-keygen -y /var/lib/sops/age/keys.txt
# → age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 4. Register the key in `.sops.yaml`

```yaml
keys:
  - &thinkpad age1...
  - &personal age1...
  - &workstation age1...
  - &newhost age1...    # paste the public key from the step above

creation_rules:
  # Secrets file for this host's SSH host key:
  - path_regex: secrets/newhost\.yaml$
    key_groups:
      - age:
          - *newhost

  # If deus is on this host, add *newhost to deus.yaml so deus's secrets
  # (SSH user key) can be decrypted on this machine:
  - path_regex: secrets/deus\.yaml$
    key_groups:
      - age:
          - *thinkpad
          - *personal
          - *workstation
          - *newhost    # add this line
```

After updating the rules for `deus.yaml`, re-encrypt it so the new host key is added:

```bash
sops updatekeys secrets/deus.yaml
```

### 5. Create the SSH host key secret

```bash
# Generate a key for the host:
ssh-keygen -t ed25519 -f /tmp/newhost_hostkey -N "" -C "root@newhost"

# Create the sops secrets file:
sops secrets/newhost.yaml
```

In the editor, add:
```yaml
ssh_host_ed25519_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste private key content here>
    -----END OPENSSH PRIVATE KEY-----
```

Clean up the temp key:
```bash
rm /tmp/newhost_hostkey /tmp/newhost_hostkey.pub
```

### 6. Stage and build

```bash
git add modules/hosts/newhost/ secrets/newhost.yaml
just install
```

### 7. Enable rclone on the new host (optional, deus only)

rclone.yaml is only decryptable by hosts listed in its creation rule. To add a new host:

```yaml
# .sops.yaml
- path_regex: secrets/rclone\.yaml$
  key_groups:
    - age:
        - *rclone
        - *personal
        - *thinkpad
        - *newhost    # add this
```

```bash
sops updatekeys secrets/rclone.yaml
```

Then add `"rclone"` to `extraAspects` in the host declaration.

---

## Adding a new user

### 1. Create the user aspect

```bash
touch modules/users/newuser.nix
git add modules/users/newuser.nix
```

```nix
# modules/users/newuser.nix
{ den, ... }:
{
  den.aspects.newuser = {
    includes = [
      den.provides.primary-user       # uid 1000 + wheel — drop this for secondary users
      (den.provides.user-shell "fish")

      den.aspects.catppuccin
      den.aspects.stylix
      den.aspects.fish
      den.aspects.ghostty
      den.aspects.git
      den.aspects.nvim
      den.aspects.secrets
      den.aspects.ssh
      den.aspects.shell-tools
      den.aspects.dms-home
      # add whatever else the user needs
    ];

    nixos.users.users.newuser = {
      description = "Full Name";
      initialPassword = "changeme";
    };

    homeManager.home.homeDirectory = "/home/newuser";
    homeManager.programs.git.settings.user = {
      name = "Full Name";
      email = "user@example.com";
    };
  };
}
```

### 2. Add the user to the relevant hosts

```nix
# modules/hosts/workstation/default.nix
den.hosts.x86_64-linux.workstation = {
  ...
  users.newuser = {
    nvimLanguages = [ "nix" "python" ];
  };
};
```

### 3. Set up their SSH key (see Secrets section below)

### 4. Build

```bash
just install
```

---

## Secrets and SSH

### How it works

Secrets are encrypted with [sops](https://github.com/getsops/sops) + age keys, and
decrypted at activation time by sops-nix. `.sops.yaml` says which age keys can decrypt
which files.

Each host has one age key. It lives in two places (same file, two paths) because
NixOS-level and home-manager-level services run as different users:

| Path | Owner | Used for |
|------|-------|----------|
| `/var/lib/sops/age/keys.txt` | root | SSH host keys, system secrets |
| `~/.config/sops/age/keys.txt` | user | SSH user keys, rclone.conf |

`just install` auto-syncs the user copy from the system copy if it's missing.

### Add a user SSH key

`ssh.nix` automatically places a user's SSH key at `~/.ssh/id_ed25519` if a file at
`secrets/<username>.yaml` exists. It checks for the file with `builtins.pathExists` —
so creating the file is all that's needed.

See `notes/secrets-user-ssh.md` for the full step-by-step. Short version for soumya
on workstation as an example:

**1. Add a creation rule to `.sops.yaml`**

```yaml
creation_rules:
  - path_regex: secrets/soumya\.yaml$
    key_groups:
      - age:
          - *workstation    # workstation's age key can decrypt this
```

**2. Generate an SSH key**

```bash
ssh-keygen -t ed25519 -f /tmp/soumya_key -N "" -C "soumya@workstation"
cat /tmp/soumya_key    # copy this
```

**3. Create the sops file**

```bash
sops secrets/soumya.yaml
```

Paste into the editor:
```yaml
ssh_user_ed25519_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    <paste the private key here>
    -----END OPENSSH PRIVATE KEY-----
```

**4. Clean up and apply**

```bash
rm /tmp/soumya_key /tmp/soumya_key.pub
git add secrets/soumya.yaml
just install
```

sops-nix places the key at `/home/soumya/.ssh/id_ed25519` (mode 0600) on activation.

### Edit an existing secrets file

```bash
sops secrets/deus.yaml    # decrypts, opens in $EDITOR, re-encrypts on save
```

### Add a new secret and use it in config

Add a key to the sops file, then reference it in a homeManager or nixos block:

```nix
# Home-manager secret — placed in the user's home
homeManager = { config, ... }: {
  sops.secrets.github_token = {
    sopsFile = ../../secrets/deus.yaml;
    path = "${config.home.homeDirectory}/.config/gh/token";
    mode = "0600";
  };
};

# System secret — placed in /etc
nixos.sops.secrets.service_key = {
  sopsFile = ../../secrets/workstation.yaml;
  path = "/etc/myservice/key";
  owner = "myservice";
  mode = "0400";
};
```

### Re-encrypt a file after adding a new key recipient

```bash
# After updating .sops.yaml to add a new age key to a file's rules:
sops updatekeys secrets/rclone.yaml
```

### Restore the age key on a fresh install

```bash
# The encrypted backup lives in the repo:
age --decrypt secrets/<hostname>-age-key.age > /tmp/keys.txt

sudo mkdir -p /var/lib/sops/age
sudo install -m 600 -o root -g root /tmp/keys.txt /var/lib/sops/age/keys.txt

mkdir -p ~/.config/sops/age
install -m 600 /tmp/keys.txt ~/.config/sops/age/keys.txt

rm /tmp/keys.txt
# Then just install
```

---

## Neovim: adding a plugin

There are two parts: the Nix side (declare the plugin, make it available) and the Lua
side (configure when and how it loads).

### Step 1 — add the plugin to `_plugins.nix`

```nix
# modules/aspects/nvim/_plugins.nix
hardtime = {
  data = hardtime-nvim;   # this is pkgs.vimPlugins.hardtime-nvim
  lazy = false;           # false = loads at startup; true = loaded on demand by lze
};
```

The key (here `hardtime`) is just a label — it doesn't matter for loading. The `data`
value is the attribute name from `pkgs.vimPlugins`. Search for it at
[search.nixos.org](https://search.nixos.org/packages?channel=unstable&type=packages)
with `vimPlugins.` prefix.

`lazy = false` puts the plugin in the `start/` packpath directory — Neovim loads it
automatically at startup. `lazy = true` puts it in `opt/` — lze loads it on demand.
Use `lazy = true` for everything except plugins that must be available immediately
(like the colorscheme, snacks, or the lazy loader itself).

### Step 2 — find the exact pname

The pname is the directory name Nix gives the plugin in the store. It's what lze uses
to identify the plugin. It does **not** always match the nixpkgs attribute name.

After building (or after `nix build`), search the store:

```bash
find /nix/store -maxdepth 3 -name "vimplugin-*hardtime*" -type d
# → /nix/store/xxxxxxxx-vimplugin-hardtime.nvim-2024-11-25
```

The pname is what comes after `vimplugin-`: `hardtime.nvim`.

A few examples of how the pname differs from the nixpkgs name:

| nixpkgs attr (`pkgs.vimPlugins.*`) | pname (use in lze) |
|------------------------------------|---------------------|
| `hardtime-nvim` | `hardtime.nvim` |
| `markview-nvim` | `markview.nvim` |
| `snacks-nvim` | `snacks.nvim` |
| `nvim-lspconfig` | `nvim-lspconfig` |
| `blink-cmp` | `blink-cmp` |
| `telescope-nvim` | `telescope.nvim` |

### Step 3 — add the Lua spec in `lua/plugins/`

```lua
-- lua/plugins/editor.lua  (or wherever it fits)
{
  'hardtime.nvim',        -- this must match the pname from step 2
  event = 'VeryLazy',     -- or ft, cmd, keys — whatever trigger makes sense
  after = function()
    require('hardtime').setup({ enabled = true })
  end,
},
```

Common triggers:

| Trigger | When it loads |
|---------|--------------|
| `event = 'DeferredUIEnter'` | after the UI is ready — good for most plugins |
| `event = 'VeryLazy'` | very late startup — for things that don't need to be fast |
| `ft = { 'lua', 'python' }` | when a specific filetype opens |
| `cmd = 'Telescope'` | when a user command is invoked |
| `keys = { '<leader>f' }` | when a keybind is triggered |

### Step 4 — rebuild

```bash
just install    # or just test if you want to try without touching the boot entry
```

### Adding an LSP / language tool

For LSPs and formatters, add the language to `_lang-defs.nix` instead of `_plugins.nix`.
Then add the language name to `nvimLanguages` in the host declaration.

```nix
# modules/aspects/nvim/_lang-defs.nix
rust = {
  packages = with pkgs; [ rust-analyzer rustfmt clippy ];
  formatters.fast = { rust = [ "rustfmt" ]; };
  linters = { rust = [ "clippy" ]; };
};
```

```nix
# modules/hosts/personal/default.nix
nvimLanguages = [ "lua" "nix" "python" "rust" ];
```

Then add the LSP config to `lua/config/lsp.lua` guarded by a category check:

```lua
local nix = require(vim.g.nix_info_plugin_name)
if nix(false, 'categories', 'rust') then
  vim.lsp.config('rust_analyzer', {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml' },
  })
end
```

---

## Neovim languages

`nvimLanguages` is set per host (applies to all users on that host) and can be overridden
per user:

```nix
den.hosts.x86_64-linux.thinkpad = {
  nvimLanguages = [ "lua" "nix" "python" "typescript" "go" "latex" ];

  users.soumya = {
    nvimLanguages = [ "nix" "lua" "python" "typescript" ];  # overrides for soumya
  };
};
```

---

## Gotchas

### Ghostty service fails with `Result: protocol`

**Symptom:** `systemctl --user status app-com.mitchellh.ghostty.service` shows
`Active: failed (Result: protocol)`.

**Cause:** A stray Ghostty process (launched directly, not via the service) holds the
D-Bus name `com.mitchellh.ghostty`. When the service starts with
`--gtk-single-instance=true`, it detects the name is taken and exits cleanly (status=0)
without sending `READY=1`. Since the service is `Type=notify-reload`, systemd waits for
that signal and reports `protocol` failure when it never arrives.

**Debug steps:**
```bash
systemctl --user status app-com.mitchellh.ghostty.service   # confirm protocol failure
pgrep -a ghostty                                             # look for a stray process
```

**Fix:** Kill the stray process (or close Ghostty), then start via the service:
```bash
pkill ghostty          # or close the window
systemctl --user start app-com.mitchellh.ghostty.service
```

**Prevention:** Always launch Ghostty via the service or D-Bus activation, never
directly from a launcher or shell. The service is enabled by `programs.ghostty.systemd.enable = true`.

---

### Ghostty shows random black/blank lines (text blacked out)

**Symptom:** Specific rows in the terminal randomly go completely black, obscuring all
text on those lines. The same rows are affected consistently within a session.

**Cause:** Stale fontconfig cache entries pointing to old nix store paths (garbage
collected after a `just clean` or `nix-collect-garbage`). Ghostty looks up a codepoint,
fontconfig returns a path from the stale cache, FreeType fails to open the font file,
and the entire row goes blank. The error shows up in journald as:

```
warning(generic_renderer): error building row y=N err=error.CannotOpenResource
```

**Debug steps:**
```bash
# Check journald for the telltale error:
journalctl --user -u app-com.mitchellh.ghostty.service --no-pager -n 50 | grep CannotOpen

# Rebuild the fontconfig cache (look for "invalid cache file" lines):
fc-cache -f -v
```

**Fix:** Rebuild the fontconfig cache and restart Ghostty:
```bash
fc-cache -f
systemctl --user restart app-com.mitchellh.ghostty.service
```

This typically happens after garbage collection removes old nix store paths that the
fontconfig cache still referenced. Running `just clean` followed by `just install`
should trigger a cache rebuild automatically, but if it doesn't, run `fc-cache -f`
manually.

---

## Reference notes

| File | What's in it |
|------|--------------|
| `notes/den.md` | den API — all options, batteries, context pipeline |
| `notes/dendritic-pattern.md` | the dendritic pattern and all seven aspect shapes |
| `notes/neovim.md` | nix-wrapper-modules, lze, lzextras, LSP setup in detail |
| `notes/secrets-user-ssh.md` | full walkthrough: sops-managed SSH key for a new user |
| `notes/avahi.md` | mDNS / local hostname resolution |
| `notes/tailscale.md` | Tailscale VPN |
| `notes/avahi-tailscale.md` | making Tailscale and Avahi coexist |
| `notes/thinkpad-graphics.md` | AMD GPU / hardware notes for thinkpad |
