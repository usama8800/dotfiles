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

  services.caddy.enable = true;
  services.caddy.virtualHosts = {
    "http://ping.jilaniplastic.com".extraConfig = ''
      respond "Pong"
    '';
    "http://procurement.jilaniplastic.com".extraConfig = ''
      reverse_proxy :5173
    '';
    "http://procurement_backend.jilaniplastic.com".extraConfig = ''
      reverse_proxy :9010
    '';
    #   "http://154.208.40.87:5173".extraConfig = ''
    #     respond "Hello, World"
    #   '';
    #   "http://factory.jilaniplastic.com:5173".extraConfig = ''
    #     respond "Hello, World"
    #   '';
  };

  services.openssh.ports = [2222];
  services.jenkins = {
    enable = true;
    port = 8080;
    prefix = "/jenkins";
  };

  system.stateVersion = "24.05";
}
