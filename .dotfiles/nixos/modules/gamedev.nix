{pkgs-unstable, ...}: {
  environment.systemPackages = with pkgs-unstable; [
    aseprite
    godot_4
  ];
}
