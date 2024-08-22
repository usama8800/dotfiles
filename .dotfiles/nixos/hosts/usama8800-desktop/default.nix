{ ... }:
{
  networking.hostName = "usama8800-desktop"; # Define your hostname.

  imports = [
    ./hardware-configuration.nix
    ../../modules/gui.nix
  ];

  fileSystems."/mnt/hdd/" = {
    device = "/dev/disk/by-uuid/02ebd296-59ba-4846-bc02-cb43c8297a7e";
    mountPoint = "/mnt/hdd";
  };
  fileSystems."/mnt/sdd/" = {
    device = "/dev/disk/by-uuid/e22d955e-8dc8-4951-93c0-82427b3dbe88";
    mountPoint = "/mnt/sdd";
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
