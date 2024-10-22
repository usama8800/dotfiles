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
    ../../modules/gaming.nix
    ../../modules/gamedev.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  system.stateVersion = "24.05";
}
