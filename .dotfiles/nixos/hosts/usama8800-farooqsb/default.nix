# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-farooqsb"; # Define your hostname.

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/gui.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure network proxy if necessary
  networking.proxy.default = "http://192.168.0.123:8080";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.interfaces.eno1.useDHCP = false;
  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "192.168.0.28";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.0.8";

  system.autoUpgrade.dates = "14:00";

  system.stateVersion = "24.05";
}
