{
  config,
  pkgs,
  ...
}: {
  home.username = "usama";
  home.homeDirectory = "/home/usama";

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      iconTheme = "breeze-dark";
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
