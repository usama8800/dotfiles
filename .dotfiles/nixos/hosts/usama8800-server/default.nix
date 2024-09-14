# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-server"; # Define your hostname.

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.ports = [2222];
  services.postgresql.ensureDatabases = ["nextcloud"];
  services.jenkins.prefix = "/jenkins";

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
