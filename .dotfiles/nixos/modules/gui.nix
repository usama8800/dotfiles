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

  virtualisation.vmware.host.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
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

    smartgithg # git client
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
    onlyoffice-bin # office suite
    pkgs.floorp # browser
    megasync # cloud storage
    nextcloud-client # cloud storage
    variety # wallpapers
    mpv # video player
    beeper # messaging app
    vesktop # discord
    freetube # privacy youtube
    krita # image editor
  ];

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs-unstable.x11vnc}/bin/x11vnc -wait 15 -noxdamage -rfbauth "$HOME"/.vnc/passwd -display :0 -forever -o /var/log/x11vnc.log -bg
  '';
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
      echo -e "[Keyboard]\nNumlock=0" > /var/lib/sddm/.config/kcminputrc;
      rm -f /usr/bin/variety;
      ln -s "${pkgs-unstable.variety}/bin/variety" /usr/bin/variety;
      sed -E -i 's/Exec=.+/Exec=\/bin\/sh -c "sleep 20 \&\& \/usr\/bin\/variety --profile \/home\/usama\/.config\/variety\/"/' /home/usama/.config/autostart/variety.desktop;
    '';
    wantedBy = ["multi-user.target"];
  };

  home-manager.users.usama = {
    programs.plasma = {
      enable = true;
      overrideConfig = false;
      hotkeys.commands = {
        konsole = {
          command = "konsole";
          key = "Meta+t";
          comment = "Open Konsole";
        };
      };
      shortcuts = {
        "systemsettings.desktop" = {
          _launch = "Meta+I";
        };
        kwin = {
          "Window Maximize" = "Meta+M";
          "Switch One Desktop to the Right" = "Meta+Ctrl+Right";
          "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
          "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
          "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
          "Window to Next Screen" = "Meta+Shift+Right";
          "Window to Previous Screen" = "Meta+Shift+Left";
          Overview = "Meta+Tab";
        };
      };
      spectacle.shortcuts.captureRectangularRegion = "Print";
      spectacle.shortcuts.launch = "Shift+Print";
      input.keyboard.numlockOnStartup = "on";
      kscreenlocker = {
        autoLock = false;
        lockOnResume = false;
        lockOnStartup = false;
        passwordRequired = false;
      };
      kwin = {
        borderlessMaximizedWindows = null;
        cornerBarrier = true;
        effects = {
          blur.enable = false;
          cube.enable = false;
          desktopSwitching.animation = "slide";
          dimAdminMode.enable = true;
          dimInactive.enable = false;
          fallApart.enable = false;
          minimization.animation = "magiclamp";
          shakeCursor.enable = true;
          slideBack.enable = false;
          translucency.enable = false;
          windowOpenClose.animation = "scale";
          wobblyWindows.enable = true;
        };
        nightLight.enable = false;
        scripts.polonium.enable = false;
        titlebarButtons.left = ["more-window-actions" "shade" "keep-above-windows"];
        titlebarButtons.right = ["help" "minimize" "maximize" "close"];
        virtualDesktops.rows = 1;
        virtualDesktops.number = 2;
      };
      panels = [
        {
          alignment = "left";
          floating = false;
          height = 44;
          hiding = "none";
          lengthMode = "fill";
          location = "bottom";
          screen = "all";
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.pager"
            "org.kde.plasma.icontasks"
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
      powerdevil = {
        AC = {
          autoSuspend.action = "nothing";
          dimDisplay.enable = true;
          dimDisplay.idleTimeOut = 300;
          powerButtonAction = "sleep";
          turnOffDisplay.idleTimeout = 600;
          turnOffDisplay.idleTimeoutWhenLocked = 30;
          whenLaptopLidClosed = "turnOffScreen";
          whenSleepingEnter = "standbyThenHibernate";
        };
        battery = {
          autoSuspend.action = "nothing";
          dimDisplay.enable = true;
          dimDisplay.idleTimeOut = 120;
          powerButtonAction = "sleep";
          turnOffDisplay.idleTimeout = 300;
          turnOffDisplay.idleTimeoutWhenLocked = 30;
          whenLaptopLidClosed = "turnOffScreen";
          whenSleepingEnter = "standbyThenHibernate";
        };
        lowBattery = {
          autoSuspend.action = "hibernate"; # or "sleep"?
          dimDisplay.enable = true;
          dimDisplay.idleTimeOut = 30;
          powerButtonAction = "sleep";
          turnOffDisplay.idleTimeout = 60;
          turnOffDisplay.idleTimeoutWhenLocked = 30;
          whenLaptopLidClosed = "sleep";
          whenSleepingEnter = "standbyThenHibernate";
        };
      };
      windows.allowWindowsToRememberPositions = true;
      workspace = {
        clickItemTo = "select";
        colorScheme = "BreezeDark";
        cursor.theme = "breeze_cursors";
        cursor.size = 24;
        iconTheme = "breeze-dark";
        lookAndFeel = "org.kde.breezedark.desktop";
        soundTheme = "ocean";
        theme = "breeze-dark";
      };
    };

    programs.kate = {
      enable = true;
      editor.font = {
        family = "JetBrains Mono";
        pointSize = 10;
      };
    };

    programs.konsole = {
      enable = true;
      defaultProfile = "Custom";
      profiles.Custom = {
        font.name = "JetBrains Mono";
      };
    };
  };
}
