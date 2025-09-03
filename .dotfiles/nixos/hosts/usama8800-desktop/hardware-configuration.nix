{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
  fileSystems."/mnt/hdd/" = {
    device = "/dev/disk/by-label/HDD";
    mountPoint = "/mnt/hdd";
  };
  fileSystems."/mnt/sdd/" = {
    device = "/dev/disk/by-label/SDD";
    mountPoint = "/mnt/sdd";
  };

  swapDevices = [{device = "/dev/disk/by-label/swap";}];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    package = config.boot.kernelPackages.nvidiaPackages.production; # (installs 550)
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
  };

  # List USB devices: `lsusb` or `grep . /sys/bus/usb/devices/*/product`
  #   Bus x Device y ID a:b
  #   Folder = x-y;  a = Vendor ID; b = Product ID
  # Check wakeup status: `grep . /sys/bus/usb/devices/*/power/wakeup`
  # Temp check as sudo: `echo enabled > /sys/bus/usb/devices/BUS-DEVICE/power/wakeup`
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="usb" ATTR{idVendor}=="1bcf" ATTR{power/wakeup}="enabled"
  '';
}
