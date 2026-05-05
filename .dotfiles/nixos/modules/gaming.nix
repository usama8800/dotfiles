{
  pkgs-unstable,
  pkgs,
  ...
}: {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.systemPackages =
    (with pkgs-unstable; [
      protonup-ng
      protontricks
      mangohud
      heroic # epic games and gog launcher
      wineWow64Packages.stable
    ])
    ++ (with pkgs; [
      lutris
      bottles
      prismlauncher
    ]);
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
  programs.nix-ld.libraries = with pkgs; [
    libGL
  ];
}
