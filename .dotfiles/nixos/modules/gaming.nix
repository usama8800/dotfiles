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
      protonup
      protontricks
      lutris
      bottles
      mangohud
      heroic # epic games and gog launcher
      wineWowPackages.stable
    ])
    ++ (with pkgs; [
      prismlauncher
    ]);
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
  programs.nix-ld.libraries = with pkgs; [
    libGL
  ];
}
