# ThinkPad T14 Gen 2a — Graphics & Hardware Configuration

## Hardware

- **Machine**: ThinkPad T14 Gen 2a (20XLCTO1WW)
- **CPU/APU**: AMD Ryzen 7 PRO 5850U (Cezanne)
- **GPU**: AMD Radeon Vega Series (integrated, `amdgpu` kernel driver)
- **Card Reader**: Realtek RTS522A PCIe Express Card Reader (`04:00.0`)
- **Display**: 1920x1080 14" 60Hz (AUO573D, built-in)

## Graphics Configuration

### What NixOS needs for AMD Cezanne iGPU

```nix
hardware.graphics = {
  enable = true;
  # extraPackages not needed for basic Wayland + GPU acceleration.
  # Mesa (including RADV Vulkan) is included automatically by enable = true.
  #
  # Optional extras if needed later:
  # extraPackages = with pkgs; [
  #   rocmPackages.clr.icd  # OpenCL compute — GPU-accelerated video transcoding
  #                         # (Handbrake/FFmpeg), photo editing (Darktable),
  #                         # local LLMs (llama.cpp ROCm), Blender GPU rendering
  # ];
};
```

### Key facts

- **RADV** (AMD Vulkan driver) is bundled inside Mesa — no separate package needed.
  `vulkan-radeon` is NOT a standalone nixpkgs attribute.
- **`libva-mesa-driver`** (VA-API) is also included in Mesa by default.
- **`amdvlk`** is being discontinued upstream — do not use; Mesa RADV is preferred.
- **`mesa` in `extraPackages` is wrong** — it's the base driver stack, already included
  by `hardware.graphics.enable = true`. Adding it explicitly causes subtle conflicts
  (was the root cause of Ghostty GPU issues on this machine).
- `hardware.graphics.enable32Bit` only needed for 32-bit apps (games, Steam) — not used here.

### Sources

- [NixOS Wiki: AMD GPU](https://wiki.nixos.org/wiki/AMD_GPU)
- [NixOS Wiki: Graphics](https://wiki.nixos.org/wiki/Graphics)
- [NixOS Discourse: AMD APU GPU compute](https://discourse.nixos.org/t/testing-gpu-compute-on-amd-apu-nixos/47060)
- [NixOS Discourse: Mesa RADV vs amdvlk](https://discourse.nixos.org/t/24-11-amd-gpu-how-to-use-mesa-radv-instead-of-amdvlk/57110)

## Card Reader Configuration

### Problem

The ThinkPad T14 Gen 2a has a **PCIe** card reader (Realtek RTS522A, `04:00.0`).
The auto-generated hardware config had `rtsx_usb_sdmmc` — the USB variant driver — which
does not apply to this hardware. SD cards would not appear as block devices.

### Fix

In `_hardware-configuration.nix` initrd:

```nix
# Wrong (USB card reader driver — not applicable):
# "rtsx_usb_sdmmc"

# Correct (PCIe card reader driver stack):
"rtsx_pci_sdmmc"   # availableKernelModules — exposes SD slot as /dev/mmcblk*
                   # rtsx_pci (base PCIe bus driver) is pulled in automatically
```

## Early KMS (Kernel Mode Setting)

Adding `amdgpu` to `boot.initrd.kernelModules` enables the GPU driver early in the boot
process — avoids flickering, ensures display is initialized before userspace.

```nix
boot.initrd.kernelModules = ["amdgpu"];
```
