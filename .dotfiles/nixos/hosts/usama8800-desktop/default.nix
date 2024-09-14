{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  networking.hostName = "usama8800-desktop";

  imports = [
    ./hardware-configuration.nix
    ../../modules/gui.nix
    ../../modules/gamedev.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # List USB devices: `lsusb` or `grep . /sys/bus/usb/devices/*/product`
  #   Bus x Device y ID a:b
  #   Folder = x-y;  a = Vendor ID; b = Product ID
  # Check wakeup status: `grep . /sys/bus/usb/devices/*/power/wakeup`
  # Temp check as sudo: `echo enabled > /sys/bus/usb/devices/BUS-DEVICE/power/wakeup`
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="usb" ATTR{idVendor}=="1bcf" ATTR{power/wakeup}="enabled"
  '';

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.systemPackages = with pkgs-unstable; [
    protonup
    lutris
    mangohud
  ];
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
  programs.nix-ld.libraries = with pkgs; [
    libGL
  ];

  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
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

  system.stateVersion = "24.05";
}
