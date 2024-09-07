{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-alien,
    home-manager,
    plasma-manager,
    disko,
    ...
  }: {
    nixosConfigurations = let
      define-host = hostname:
        nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit self system;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./modules/system.nix
            ./hosts/${hostname}
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [plasma-manager.homeManagerModules.plasma-manager];
            }

            ({
              self,
              system,
              ...
            }: {
              nixpkgs.overlays = [
                self.inputs.nix-alien.overlays.default
              ];
              # Optional, needed for `nix-alien-ld`
              programs.nix-ld.enable = true;
            })
          ];
        };
    in {
      usama8800-desktop = define-host "usama8800-desktop";
      usama8800-farooqsb = define-host "usama8800-farooqsb";
      usama8800-server = define-host "usama8800-server";
      usama8800-vm = define-host "usama8800-vm";
      anywhere = define-host "anywhere";
    };
  };
}
