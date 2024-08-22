{ pkgs-unstable, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  systemd.services.display-manager.wants = [ "systemd-user-sessions.service" "multi-user.target" "network-online.target" ];
  systemd.services.display-manager.after = [ "systemd-user-sessions.service" "multi-user.target" "network-online.target" ];
  services.desktopManager.plasma6.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "usama";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs-unstable; [
    unzip
    libnotify
    kdePackages.kfind
    kdePackages.partitionmanager
    kdePackages.filelight
    speedcrunch

    kdePackages.kate
    vscode
    obsidian
    beekeeper-studio
    onlyoffice-bin

    google-chrome
    thunderbird-bin
    megasync
    variety
    mpv
    beeper
    vesktop
  ];
  systemd.user.services.megasync = {
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs-unstable.megasync}/bin/megasync";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
  };
  systemd.user.services.variety = {
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs-unstable.variety}/bin/variety";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
  };
  systemd.user.services.vesktop = {
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs-unstable.vesktop}/bin/vesktop";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
  };
  systemd.user.services.beeper = {
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs-unstable.beeper}/bin/beeper";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
  };
  systemd.user.services.thunderbird-bin = {
    serviceConfig = {
      PassEnvironment = "DISPLAY";
      ExecStart = "${pkgs-unstable.thunderbird-bin}/bin/thunderbird";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
  };
}
