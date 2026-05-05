{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-alien,
    home-manager,
    plasma-manager,
    nix-index-database,
    ...
  }: {
    nixosConfigurations = let
      define-host = hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit self inputs;
            system = "x86_64-linux";
            pkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            ./modules/system.nix
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            nix-index-database.nixosModules.default
            {
              home-manager.sharedModules = [plasma-manager.homeModules.plasma-manager];
            }
            ({
              self,
              system,
              ...
            }: {
              nixpkgs.overlays = [
                self.inputs.nix-alien.overlays.default
                (final: prev: {
                  mpv = prev.mpv.override {
                    scripts = [final.mpvScripts.mpris];
                  };
                })
              ];
            })
            {
              nix.registry = {
                nixpkgs.flake = nixpkgs;
                nixpkgs-unstable.flake = nixpkgs-unstable;
              };
            }
          ];
        };
    in {
      usama8800-desktop = define-host "usama8800-desktop";
      usama8800-lenovo = define-host "usama8800-lenovo";
      usama8800-server = define-host "usama8800-server";
    };
  };
}
