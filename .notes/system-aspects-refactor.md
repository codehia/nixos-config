# System Aspects Refactor Plan

## Status

**Partially done** (2026-03-16):
- `modules/system/networking.nix` ✅
- `modules/system/greetd.nix` ✅
- `modules/system/pipewire.nix` ✅
- `modules/system/graphics.nix` ✅
- `modules/system/ios-devices.nix` ✅
- `modules/system/zram.nix` ✅
- `modules/system/base.nix` ⏳ — paused, user wants to break it down further (see below)
- Host files not yet updated to use new aspects ⏳

---

## Context

All three host files (`thinkpad.nix`, `personal.nix`, `workstation.nix`) have significant
duplicated NixOS config. The goal is to extract shared config into dendritic aspects under
`modules/system/`.

---

## Completed Aspects

### `den.aspects.networking`
- `networking.networkmanager.enable = true`
- `networking.firewall.trustedInterfaces = ["tailscale0"]`
- `networking.firewall.checkReversePath = "loose"`
- Note: tailscale *service* stays in hosts (workstation uses custom package/port)

### `den.aspects.greetd { username, session }`
- Parameterized tuigreet-backed greetd
- `session` needs to move to outer let block in each host (it's currently in `nixos` let)

### `den.aspects.pipewire`
- `services.pipewire.enable = true`
- `services.pipewire.pulse.enable = true`
- `services.pipewire.wireplumber.enable = true`
- Host-specific extras stay in hosts:
  - thinkpad: `wireplumber.extraConfig.bluetoothPolicy`
  - personal: `alsa = { enable = true; support32Bit = true; }`

### `den.aspects.graphics`
- `hardware.graphics.enable = true`
- Mesa (RADV Vulkan + VA-API) included automatically
- Host-specific extras (OpenCL etc.) stay in hosts

### `den.aspects.ios-devices`
- `services.usbmuxd.enable = true`
- packages: `libimobiledevice`, `ifuse`, `idevicerestore`
- Used by: personal + thinkpad (not workstation)

### `den.aspects.zram`
- `zramSwap = { enable = true; priority = 100; algorithm = "lz4"; memoryPercent = 50; }`
- Currently: personal + thinkpad. Workstation to be added eventually.

---

## Pending: `base.nix` (needs further breakdown)

Currently planned as one aspect containing:
- `security.sudo.wheelNeedsPassword = false`
- `programs.fish.enable = true`
- `programs.dconf.enable = true`
- `environment.systemPackages = [vim wget git fish]`

User wants to break this down further. Possible splits:
- `den.aspects.sudo` — just `security.sudo.wheelNeedsPassword = false`
- `den.aspects.dconf` — just `programs.dconf.enable = true` (fixes workstation oversight too)
- Base packages absorbed into existing `packages.nix` aspect or a new `core-packages` aspect
- `programs.fish.enable` could move to the existing `fish.nix` aspect (system-level fish alongside home-manager fish config)

---

## Host Updates Required (after base.nix is resolved)

### All three hosts — add to `includes`:
```nix
den.aspects.base          # (or whatever base.nix becomes)
den.aspects.networking
(den.aspects.greetd { inherit username session; })
den.aspects.pipewire
den.aspects.graphics
```

### personal + thinkpad only — add to `includes`:
```nix
den.aspects.ios-devices
den.aspects.zram
```

### Each host nixos block — remove after extraction:
- `zramSwap` block
- `networking.networkmanager.enable` + firewall config
- `security.sudo.wheelNeedsPassword = false`
- `vim wget git fish` from systemPackages
- `libimobiledevice ifuse idevicerestore` from systemPackages (personal + thinkpad)
- `programs.dconf.enable`, `programs.fish.enable`
- `services.usbmuxd.enable` (personal + thinkpad)
- `services.greetd` block
- `services.pipewire.enable + pulse.enable + wireplumber.enable`
- `hardware.graphics.enable = true`

### Per-host let block changes:
- Remove `tuigreet` let binding (moves to greetd aspect)
- Move `session` from `nixos` let block to outer let block (needed in `includes`)

### Fix `mesa` bug on personal + workstation:
Both still have `extraPackages = with pkgs; [mesa ...]` — remove `mesa` (same bug as thinkpad).
personal: remove entire `hardware.graphics` block (covered by graphics aspect).
workstation: remove `mesa` from extraPackages, keep `rocmPackages.clr.icd` if desired.

### workstation — add `dconf`:
Was an oversight. Will be covered by `base` aspect once implemented.
