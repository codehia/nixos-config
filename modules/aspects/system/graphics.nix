# GPU acceleration baseline.
# Mesa (RADV Vulkan + VA-API via radeonsi) is included automatically by enable = true.
# No extraPackages needed for RDNA1 — Mesa covers VA-API out of the box.
# NOTE: ROCm/OpenCL does NOT support gfx1012 (RX 5500 XT) — skip hardware.amdgpu.opencl.enable.
{
  den.aspects.graphics = {
    nixos.hardware = {
      graphics = {
        enable = true;
        # enable32Bit = true;  # Uncomment when Steam/Proton needed
      };
      amdgpu.initrd.enable = true; # Loads amdgpu in initramfs (replaces manual kernelModules entry)
    };
  };
}
