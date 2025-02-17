{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  system.autoUpgrade.enable = false;
  services.power-profiles-daemon.enable = false;
  powerManagement.enable = true;
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "passive";

      MEM_SLEEP_ON_AC = "deep";
      MEM_SLEEP_ON_BAT = "deep";

      START_CHARGE_THRESH_BAT0 = 0;
      START_CHARGE_THRESH_BAT1 = 0;
      STOP_CHARGE_THRESH_BAT0 = 1;
      STOP_CHARGE_THRESH_BAT1 = 1;

      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };
}
