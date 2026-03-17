# GPU acceleration baseline.
# Mesa (including RADV Vulkan + VA-API) is included automatically by enable = true.
# Host-specific extras (OpenCL, etc.) are declared in the host aspect.
_: {
  den.aspects.graphics = {
    nixos = _: {
      hardware.graphics.enable = true;
    };
  };
}
