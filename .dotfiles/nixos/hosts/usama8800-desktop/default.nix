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
    ../../modules/virtualization.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme1n1";
  boot.loader.grub.useOSProber = true;

  nix.settings.build-dir = "/mnt/hdd/nix/builds";

  powerManagement.resumeCommands = ''
    date -Iseconds > /mnt/hdd/Workspace/desktop-server/events/wakeup_time
  '';
  systemd.user.services.desktop-server = {
    path = [pkgs.xclip pkgs.wl-clipboard pkgs.alsa-utils];
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_22}/bin/node /mnt/hdd/Workspace/desktop-server/out/server.js";
      WorkingDirectory = "/mnt/hdd/Workspace/desktop-server/";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };

  services.prowlarr.enable = true;
  networking.hosts."127.0.0.1" = ["prowlarr"];
  services.caddy = {
    enable = true;
    virtualHosts."http://prowlarr" = {
      extraConfig = ''
        reverse_proxy localhost:9696
      '';
    };
  };

  system.stateVersion = "24.05";
}
