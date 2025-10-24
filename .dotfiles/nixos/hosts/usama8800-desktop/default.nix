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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.displayManager.ly.enable = false;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    wayland.compositor = "kwin";
    autoNumlock = true;
  };

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
