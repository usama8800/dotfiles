{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    # ../../modules/system.nix
    # ../../modules/gui.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.kernelParams = ["boot.shell_on_fail"];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAH3VlNgMTY5pjrKWUDGu39WMcpCfiK0fwjWdwOkXDFT" # usama8800-desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0JGch0tl4eyI947ysKtqsMIOuc7o5aiz9IqHS9ZuG6" # usama8800-office
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDv+d9OfB8GRCirJEecyQxtYfQqc/WLqL4F1qxNpBOZQ" # usama8800-lenovo
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEo0SAQiP5h7xNUAIyPCBS8ty204K+glVQj614JujX0" # usama8800-server
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.vim
    pkgs.git
  ];

  system.stateVersion = "24.05";
}
