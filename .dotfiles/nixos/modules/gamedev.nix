{
  pkgs,
  pkgs-unstable,
  ...
}: {
  environment.systemPackages = with pkgs-unstable; [
    pkgs.aseprite
    godot_4
  ];
}
