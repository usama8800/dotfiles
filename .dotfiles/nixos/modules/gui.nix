{
  lib,
  inputs,
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
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  programs.noisetorch.enable = true;

  environment.systemPackages =
    (with pkgs; [
      xorg.libxcvt
      clinfo
      virtualglLib
      vulkan-tools
      wayland-utils
      pciutils
      aha
      fwupd
      xclip # pipe to clipboard
      libnotify # notify-send
      libsForQt5.kconfig # kde config cli
      kdocker # put any app in the system tray

      protonvpn-gui # vpn
      mpv # video player
      fooyin # audio player
      audacity # audio recorder / editor
      speedcrunch # calculator
      vscode # code editor
      obsidian # markdown editor
      xournalpp # handwritten note taking
      dbeaver-bin # database browser
      variety # wallpapers
      bruno # rest client
      deluge # torrent client
      pureref # notes with imgaes
      easyeffects # microphone preprocessing
    ])
    ++ (with pkgs-unstable; [
      tigervnc # vncpasswd

      kdePackages.kfind # file finder
      kdePackages.partitionmanager # partition manager
      kdePackages.filelight # disk usage analyzer
      remmina # rdp / vnc client
      anydesk # remote server and cliet
      localsend # LAN file sharing
      # rustdesk # remote server and cliet
      kdePackages.kate # text editor
      onlyoffice-bin # office suite
      libreoffice-qt-fresh # office suite
      hunspell # libre office spell check
      hunspellDicts.uk_UA # libre office spell check
      floorp # browser
      google-chrome # browser
      nextcloud-client # cloud storage
      beeper # messaging app
      discord # messaging app
      wechat-uos # wechat
      krita # image editor
      kdePackages.kdenlive # video editor
      obs-studio # screen recorder
      # inputs.tagstudio.packages.${pkgs.stdenv.hostPlatform.system}.tagstudio
    ]);
  programs.kdeconnect.enable = true; # phone to pc connection
  environment.sessionVariables = {
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  # Set password with `vncpasswd ~/.vnc/passwd`
  systemd.user.services.vnc = {
    serviceConfig = {
      ExecStart = "${pkgs.tigervnc}/bin/x0vncserver \
        -display :0 \
        -rfbauth %h/.vnc/passwd \
        -rfbport 5900";
    };
    after = ["graphical.target"];
    wantedBy = ["default.target"];
  };
  systemd.user.services.nextcloud = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.nextcloud-client}/bin/nextcloud --background";
      Restart = "on-failure";
      RestartSec = 5;
    };
    wantedBy = ["default.target"];
    after = ["graphical.target"];
  };
  systemd.user.services.discord = {
    serviceConfig = {
      ExecStart = "${pkgs-unstable.discord}/bin/discord --start-minimized";
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
