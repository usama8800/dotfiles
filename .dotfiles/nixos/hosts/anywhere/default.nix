{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "anywhere"; # Define your hostname.

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../modules/system.nix
    # ../../modules/gui.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.grub.device = "/dev/sda";

  system.stateVersion = "24.05";
}
