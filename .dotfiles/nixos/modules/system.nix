{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  # Keep here for rebuild script
  # system.nixos.label = "REPLACE_ME";

  system.autoUpgrade = {
    enable = true;
    flake = "${config.users.users.usama.home}/.dotfiles/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "00:00";
    randomizedDelaySec = "45min";
  };

  boot.supportedFilesystems = ["ntfs"];

  # Enable networking
  networking.networkmanager.enable = true;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.usama = {
    isNormalUser = true;
    description = "Usama Ahsan";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAH3VlNgMTY5pjrKWUDGu39WMcpCfiK0fwjWdwOkXDFT" # usama8800-desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0JGch0tl4eyI947ysKtqsMIOuc7o5aiz9IqHS9ZuG6" # usama8800-office
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDv+d9OfB8GRCirJEecyQxtYfQqc/WLqL4F1qxNpBOZQ" # usama8800-lenovo
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

  # Set your time zone.
  time.timeZone = lib.mkDefault "Asia/Karachi";
  # Select internationalisation properties.
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

  fonts.packages = with pkgs; [fira-code];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    ports = [22];
    openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nix-index
    nil
    nix-alien
    alejandra

    usbutils
    fzf
    ripgrep
    xclip
    neofetch
    bat
    atuin
    zoxide
    eza
    broot
    ncdu
    pkgs-unstable.yt-dlp
    pkgs-unstable.ffmpeg_7
    pkgs-unstable.atomicparsley

    git
    lazygit
    vim
    fnm
    python3
    python312Packages.pip
  ];
  programs.git.config = {
    user.name = "Usama Ahsan";
    user.email = "usama8800@gmail.com";
  };
  services = {
    postgresql.enable = true;
    postgresql.package = pkgs.postgresql_15;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    # Use nix-alient-find-libs to find what to add
    stdenv.cc.cc.lib
    # node
    glib
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
}
