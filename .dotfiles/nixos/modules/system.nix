{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # Keep here for rebuild script
  # system.nixos.label = "REPLACE_ME";

  # manually: nix flake update; rebuild update
  system.autoUpgrade = {
    enable = true;
    flake = "${config.users.users.usama.home}/.dotfiles/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = lib.mkDefault "00:00";
    randomizedDelaySec = "15min";
  };

  boot.supportedFilesystems = ["ntfs"];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Define a user account. Don't forget to change password with ‘passwd’.
  users.users.usama = {
    isNormalUser = true;
    description = "Usama Ahsan";
    extraGroups = ["networkmanager" "wheel" "docker"];
    initialPassword = "123";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAH3VlNgMTY5pjrKWUDGu39WMcpCfiK0fwjWdwOkXDFT" # usama8800-desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0JGch0tl4eyI947ysKtqsMIOuc7o5aiz9IqHS9ZuG6" # usama8800-office
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBggZsRBOrgwDyVwDlaGlvRw/X/c7U0vsUK7G9I/IJD" # usama8800-lenovo
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEo0SAQiP5h7xNUAIyPCBS8ty204K+glVQj614JujX0" # usama8800-server
    ];
  };
  security.sudo.extraRules = [
    {
      users = ["usama"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  time.timeZone = lib.mkDefault "Asia/Karachi";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  i18n.supportedLocales = [
    "en_GB.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ur_PK/UTF-8"
  ];

  fonts.packages = with pkgs; [fira-code jetbrains-mono];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    ports = lib.mkDefault [22];
    openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = 1;
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # To search, run: nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    nix-index # for nix-locate
    nix-alien # for nix-alien-find-libs for nix-ld

    # Development tools
    git
    nil # nix language server
    alejandra # nix code formatter
    python3
    # python -m venv .venv --copies; source .venv/bin/activate
    # nix shell github:GuillaumeDesforges/fix-python
    # fix-python --venv .venv
    python312Packages.pip
    nodejs_22
    shfmt # shell formatter
    just # command runner

    # for python scripts
    pkgs-unstable.yt-dlp
    pkgs-unstable.ffmpeg_7
    pkgs-unstable.atomicparsley

    usbutils
    unzip
    rclone
    wakeonlan
    util-linux # for cfdisk ( tui partition manager )
    zellij # terminal multiplexer
    parted # partition manager
    fzf # fuzzy finder
    ripgrep # better grep
    xclip # pipe to clipboard
    neofetch # styled system info
    bat # better cat
    atuin # shell history
    zoxide # better cd
    eza # better ls

    vim
    btop # system monitor
    lazygit # git client
    lazydocker # docker client
    broot # file manager
    ncdu # disk usage analyzer
    ventoy-full # bootable usb
  ];
  programs.git.config = {
    user.name = "Usama Ahsan";
    user.email = "usama8800@gmail.com";
  };
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.flags = ["--all"];
    autoPrune.dates = "weekly";
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # type database DBuser origin-address auth-method
      local  all      all                   trust
      host   all      all    127.0.0.1/32   scram-sha-256
      host   all      all    ::1/128        scram-sha-256
      host   all      all    172.0.0.0/8    scram-sha-256
    '';
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Use nix-alien-find-libs to find what to add
    # or nix-index then nix-locate --top-level libname.so
    stdenv.cc.cc.lib
    zlib
    libpulseaudio
    # node
    glib
    # mpv mpris
    ffmpeg_4.lib
    # cypress
    libgcc
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hmbak";
  home-manager.users.usama = {
    home.username = "usama";
    home.homeDirectory = "/home/usama";

    editorconfig.enable = true;
    editorconfig.settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_width = 100;
        indent_style = "space";
        indent_size = 2;
      };
      "md" = {
        trim_trailing_whitespace = false;
      };
    };

    programs.home-manager.enable = true;
    home.stateVersion = "24.05";
  };
}
