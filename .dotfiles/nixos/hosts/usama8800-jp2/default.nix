{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-jp2";

  imports = [
    ./hardware-configuration.nix
    ../../modules/gui.nix
    # ../../modules/gamedev.nix
    ../../modules/gaming.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade.dates = "16:00";

  system.stateVersion = "24.05";
}
