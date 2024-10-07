{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "usama8800-lenovo";

  imports = [
    ./hardware-configuration.nix
    ../../modules/laptop.nix
    ../../modules/gui.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.autoUpgrade.dates = "14:00";

  home-manager.users.usama.programs.plasma.configFile = {
    kcminputrc = {
      "Libinput/1267/12370/ELAN0651:00 04F3:3052 Touchpad" = {
        ClickMethod = 2;
        NaturalScroll = true;
        ScrollFactor = 0.5;
      };
      "Libinput/1386/20728/Wacom HID 50F8 Finger".Enabled = false;
    };
    kwinrc = {
      Xwayland.Scale = 1.1;
    };
  };

  systemd.timers."conservation-off" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 16:00:00";
      Unit = "conservation-off.service";
    };
  };
  systemd.services."conservation-off".script = ''echo 0 | tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'';

  systemd.timers."conservation-on" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 16:30:00";
      Persistent = true;
      Unit = "conservation-on.service";
    };
  };
  systemd.services."conservation-on".script = ''echo 1 | tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'';

  system.stateVersion = "24.05";
}
