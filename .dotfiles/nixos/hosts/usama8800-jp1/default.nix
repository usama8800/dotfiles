{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-jp1";

  imports = [
    ./hardware-configuration.nix
    ../../modules/gui.nix
    ../../modules/gamedev.nix
    ../../modules/gaming.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  home-manager.users.usama.programs.ssh.matchBlocks = {
    server = {
      host = "server";
      user = "usama";
      port = 2222;
      hostname = "192.168.0.123";
    };
    git = {
      host = "github.com";
      user = "git";
      port = 2223;
      hostname = "192.168.0.123";
    };
    factory = {
      host = "factory";
      user = "usama";
      port = 2224;
      hostname = "192.168.0.123";
    };
  };

  system.stateVersion = "24.05";
}
