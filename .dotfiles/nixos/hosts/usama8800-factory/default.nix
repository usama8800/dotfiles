{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-factory";

  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.interfaces.eno1.useDHCP = false;
  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "216.236.100.126";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "216.236.100.1";
  networking.nameservers = [
    "216.236.100.1"
  ];

  services.openssh.ports = [2222];
  services.jenkins = {
    enable = true;
    port = 8080;
    prefix = "/jenkins";
  };

  system.stateVersion = "24.05";
}
