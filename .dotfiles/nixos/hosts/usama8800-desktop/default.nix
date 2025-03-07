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
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  powerManagement.resumeCommands = ''
    date -Iseconds > /mnt/hdd/Workspace/desktop-server/events/wakeup_time
  '';
  systemd.user.services.desktop-server = {
    path = [pkgs.xclip];
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_22}/bin/node /mnt/hdd/Workspace/desktop-server/out/server.js";
      WorkingDirectory = "/mnt/hdd/Workspace/desktop-server/";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };

  system.stateVersion = "24.05";
}
