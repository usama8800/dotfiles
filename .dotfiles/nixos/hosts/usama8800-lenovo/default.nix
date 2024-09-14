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

  system.stateVersion = "24.05";
}
