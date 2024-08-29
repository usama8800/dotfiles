{
  pkgs,
  pkgs-unstable,
  ...
}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.wayland.compositor = "kwin";
  services.displayManager.sddm.autoNumlock = true;
  services.desktopManager.plasma6.enable = true;
  # systemd.services.display-manager.wants = ["systemd-user-sessions.service" "multi-user.target" "network-online.target"];
  # systemd.services.display-manager.after = ["systemd-user-sessions.service" "multi-user.target" "network-online.target"];
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = false;
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
    xorg.libxcvt
    unzip
    clinfo
    virtualglLib
    vulkan-tools
    wayland-utils
    pciutils
    aha
    fwupd
    libnotify
    kdocker

    smartgithg
    kdePackages.kfind
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kate
    speedcrunch
    anydesk
    vscode
    obsidian
    beekeeper-studio
    onlyoffice-bin

    google-chrome
    megasync
    variety
    mpv
    beeper
    vesktop
  ];

  systemd.user.services.megasync = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.megasync}/bin/megasync";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };
  systemd.user.services.vesktop = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.vesktop}/bin/vesktop --start-minimized";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };
  systemd.user.services.beeper = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.beeper}/bin/beeper --hidden";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };
  # ${pkgs-unstable.kdocker} -d 60 -q -o -l COMMAND
  systemd.services.bins = {
    script = ''
      /bin/sh -c '
        echo =e "[Keyboard]\nNumlock=0" > /var/lib/sddm/.config/kcminputrc
        rm -f /usr/bin/variety;
        ln -s "${pkgs-unstable.variety}/bin/variety" /usr/bin/variety;
      '
    '';
    wantedBy = ["multi-user.target"];
  };
}
