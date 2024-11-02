{lib, ...}: {
  home-manager.users.usama = {
    programs.plasma = {
      enable = true;
      overrideConfig = lib.mkDefault false;
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
        "org.kde.krunner.desktop" = {
          _launch = "Meta+Space";
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
          dimDisplay.idleTimeout = 300;
          powerButtonAction = "sleep";
          turnOffDisplay.idleTimeout = 600;
          turnOffDisplay.idleTimeoutWhenLocked = 30;
          whenLaptopLidClosed = "doNothing";
          whenSleepingEnter = "standbyThenHibernate";
        };
        battery = {
          autoSuspend.action = "nothing";
          dimDisplay.enable = true;
          dimDisplay.idleTimeout = 120;
          powerButtonAction = "sleep";
          turnOffDisplay.idleTimeout = 300;
          turnOffDisplay.idleTimeoutWhenLocked = 30;
          whenLaptopLidClosed = "doNothing";
          whenSleepingEnter = "standbyThenHibernate";
        };
        lowBattery = {
          autoSuspend.action = "hibernate";
          dimDisplay.enable = true;
          dimDisplay.idleTimeout = 30;
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
      configFile = {
        ktrashrc = {
          "\\/home\\/usama\\/.local\\/share\\/Trash" = {
            LimitReachedAction = 0;
            Days = 7;
            UseTimeLimit = true;
            Percent = 5;
            UseSizeLimit = true;
          };
        };
        # Plasma Search
        kuriikwsfilterrc.General = {
          DefaultWebShortcut = "startpage";
          EnableWebShortcuts = true;
          KeywordDelimiter = "\s";
          PreferredWebShortcuts = "startpage,youtube,google,wikipedia";
          UsePreferredWebShortcutsOnly = false;
        };
        # Pulse Audio
        plasmaparc.General.RaiseMaximumVolume = true;
        spectaclerc = {
          Annotations.annotationToolType = 8;
          General = {
            autoSaveImage = true;
            clipboardGroup = "PostScreenshotCopyImage";
            launchAction = "UseLastUsedCapturemode";
            printKeyRunningAction = "FocusWindow";
            showMagnifier = "ShowMagnifierAlways";
          };
          GuiConfig = {
            captureMode = 5;
            captureOnClick = true;
            quitAfterSaveCopyExport = true;
          };
          ImageSave = {
            imageFilenameTemplate = "<yyyy>-<MM>-<dd>_<hh>-<mm>-<ss>";
            translatedScreenshotsFolder = "Screenshots";
          };
          VideoSave = {
            preferredVideoFormat = 0;
            translatedScreencastsFolder = "Screencasts";
            videoFilenameTemplate = "<yyyy>-<MM>-<dd>_<hh>-<mm>-<ss>";
          };
        };
        dolphinrc = {
          MainWindow.MenuBar = "Enabled";
          General = {
            AutoExpandFolders = true;
            BrowseThroughArchives = true;
            FilterBar = true;
            GlobalViewProps = false;
            RememberOpenedTabs = false;
            ShowFullPath = true;
            UseTabForSwitchingSplitView = true;
          };
          ContentDisplay.DirectorySizeCount = false;
          ContentDisplay.UsePermissionsFormat = "CombinedFormat";
        };
        katerc = {
          General."Startup Session" = "last";
          Konsole.AutoSyncronize = true;
        };
      };
      dataFile = {
        "kate/anonymous.katesession" = {
          "Kate Plugins" = {
            cmaketoolsplugin = false;
            compilerexplorer = false;
            eslintplugin = false;
            externaltoolsplugin = false;
            formatplugin = false;
            katebacktracebrowserplugin = false;
            katebuildplugin = false;
            katecloseexceptplugin = false;
            katecolorpickerplugin = false;
            katectagsplugin = false;
            katefilebrowserplugin = true;
            katefiletreeplugin = false;
            kategdbplugin = false;
            kategitblameplugin = false;
            katekonsoleplugin = true;
            kateprojectplugin = false;
            katereplicodeplugin = false;
            katesearchplugin = true;
            katesnippetsplugin = false;
            katesqlplugin = false;
            katesymbolviewerplugin = false;
            katexmlcheckplugin = false;
            katexmltoolsplugin = false;
            keyboardmacrosplugin = false;
            ktexteditorpreviewplugin = false;
            latexcompletionplugin = false;
            lspclientplugin = false;
            openlinkplugin = false;
            rainbowparens = true;
            rbqlplugin = false;
            tabswitcherplugin = false;
            textfilterplugin = true;
          };
          "Plugin:katefilebrowserplugin:MainWindow:0" = {
            "Allow Expansion" = false;
            "Show hidden files" = true;
            "Sort by" = "Name";
            "Sort directories first" = true;
            "Sort hidden files last" = true;
            "View Style" = "Tree";
            "auto sync folder" = true;
          };
        };
        "dolphin/view_properties/global/.directory" = {
          Dolphin.SortHiddenLast = true;
          Settings.HiddenFilesShown = true;
          DetailsMode.PreviewSize = 32;
          IconsMode.PreviewSize = 64;
        };
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
