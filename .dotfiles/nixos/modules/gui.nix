{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [./home-manager.nix];

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
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "usama";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.vmware.host.enable = true;
  environment.systemPackages = with pkgs-unstable; [
    xorg.libxcvt
    clinfo
    virtualglLib
    vulkan-tools
    wayland-utils
    pciutils
    aha
    fwupd
    libnotify # notify-send
    libsForQt5.kconfig # kde config cli
    kdocker # put any app in the system tray
    x11vnc

    kdePackages.kfind # file finder
    kdePackages.partitionmanager # partition manager
    kdePackages.filelight # disk usage analyzer
    kdePackages.kate # text editor
    remmina # rdp / vnc client
    anydesk # remote server and cliet
    speedcrunch # calculator
    vscode # code editor
    obsidian # markdown editor
    beekeeper-studio # database browser
    dbeaver-bin # database browser
    onlyoffice-bin # office suite
    floorp # browser
    nextcloud-client # cloud storage
    variety # wallpapers
    mpv # video player
    pkgs.beeper # messaging app
    vesktop # discord
    krita # image editor
    google-chrome # browser
    protonvpn-gui # vpn
    xournalpp # handwritten note taking
    postman # rest client
  ];
  environment.sessionVariables = {
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs-unstable.x11vnc}/bin/x11vnc -wait 15 -noxdamage -rfbauth "$HOME"/.vnc/passwd -display :0 -forever -o /var/log/x11vnc.log -bg
  '';
  systemd.user.services.nextcloud = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.nextcloud-client}/bin/nextcloud --background";
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
  systemd.services.bins = {
    script = ''
      mkdir -p /var/lib/sddm/.config;
      echo -e "[Keyboard]\nNumlock=0" > /var/lib/sddm/.config/kcminputrc;
      rm -f /usr/bin/variety;
      ln -s "${pkgs-unstable.variety}/bin/variety" /usr/bin/variety;
      sed -E -i 's/Exec=.+/Exec=\/bin\/sh -c "sleep 20 \&\& \/usr\/bin\/variety --profile \/home\/usama\/.config\/variety\/"/' /home/usama/.config/autostart/variety.desktop;
    '';
    wantedBy = ["multi-user.target"];
  };
}
