{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-server";

  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.ports = [2222];
  services.postgresql.ensureDatabases = ["nextcloud"];
  services.jenkins = {
    enable = true;
    port = 8080;
    prefix = "/jenkins";
  };

  systemd.timers."erp-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
      Unit = "erp-backup.service";
    };
  };
  systemd.services."erp-backup" = {
    path = [pkgs.bash pkgs.rclone];
    serviceConfig = {
      Type = "oneshot";
      User = "usama";
      WorkingDirectory = "/home/usama/Documents/erp/backups/";
      ExecStart = "/home/usama/Documents/erp/backups/cron.sh";
    };
  };

  systemd.timers."arr-trakt-delete" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "30m";
      Unit = "arr-trakt-delete.service";
    };
  };
  systemd.services."arr-trakt-delete" = {
    path = [pkgs.nodejs_22];
    serviceConfig = {
      Type = "oneshot";
      User = "usama";
      WorkingDirectory = "/home/usama/Documents/arr-trakt-delete";
    };
    script = "node ./out/index.js";
  };

  system.stateVersion = "24.05";
}
