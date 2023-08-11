{ inputs, lib, config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "cognixm";
  system.stateVersion = "23.05";
  time.timeZone = "Asia/Kolkata";
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  boot = {
    kernelParams = [ "quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
    consoleLogLevel = 0;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    initrd = {
      luks.devices."root".allowDiscards = true;
      verbose = false;
      systemd.enable = true;
      availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "rtsx_pci_sdmmc" ];
      kernelModules = [ "amdgpu" ];
    };
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };
  users.users = {
    agam = {
      initialPassword = "password";
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };
}
