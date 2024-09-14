# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-lenovo"; # Define your hostname.

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/laptop.nix
    ../../modules/gui.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade.dates = "14:00";

  home-manager.users.usama.programs.plasma.configFile = {
    kcminputrc = {
      "Libinput/1267/12370/ELAN0651:00 04F3:3052 Touchpad" = {
        ClickMethod = 2;
        NaturalScroll = true;
        ScrollFactor = 0.5;
      };
      "Libinput/1386/20728/Wacom HID 50F8 Finger".Enabled = false;
    };
    kwinrc = {
      Xwayland.Scale = 1.1;
    };
  };

  system.stateVersion = "24.05";
}
