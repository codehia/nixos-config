# Compressed swap in RAM using lz4. Currently on personal + thinkpad;
# intended for all machines eventually.
{
  den.aspects.zram = {
    nixos.zramSwap = {
      enable = true;
      priority = 100;
      algorithm = "lz4";
      memoryPercent = 50;
    };
  };
}
