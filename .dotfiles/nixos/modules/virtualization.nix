{...}: {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["usama"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  home-manager.users.usama.dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
