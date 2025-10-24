{
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  networking.hostName = "usama8800-jilani-center";

  imports = [
    ./hardware-configuration.nix
    ../../modules/gui.nix
    ../../modules/gaming.nix
    ../../modules/virtualization.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}
