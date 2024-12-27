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
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.caddy.enable = true;
  services.caddy.virtualHosts = {
    "http://ping.jilaniplastic.com".extraConfig = ''
      respond "Pong"
    '';
    "http://procurement_backend.jilaniplastic.com".extraConfig = ''
      reverse_proxy :9011
    '';
    "http://procurement.jilaniplastic.com".extraConfig = ''
      root /var/www/procurement
      handle {
        file_server {
          pass_thru
        }
        encode zstd gzip
        try_files {path} {path}.html
      }
      handle {
        file_server
        rewrite * /index.html
      }
    '';
  };

  services.openssh.ports = [2222];
  services.jenkins = {
    enable = true;
    port = 8080;
    prefix = "/jenkins";
  };

  system.stateVersion = "24.05";
}
