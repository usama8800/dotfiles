# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-vm"; # Define your hostname.

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/gui.nix
  ];

  system.stateVersion = "24.05";
}
