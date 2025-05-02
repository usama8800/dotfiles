{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # tagstudio.url = "github:TagStudioDev/TagStudio";
    # tagstudio.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-alien,
    home-manager,
    plasma-manager,
    ...
  }: {
    nixosConfigurations = let
      define-host = hostname:
        nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit self system inputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./modules/system.nix
            ./hosts/${hostname}
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
            })
          ];
        };
    in {
      usama8800-desktop = define-host "usama8800-desktop";
      usama8800-lenovo = define-host "usama8800-lenovo";
      usama8800-jp1 = define-host "usama8800-jp1";
      usama8800-jp2 = define-host "usama8800-jp2";
      usama8800-server = define-host "usama8800-server";
      usama8800-factory = define-host "usama8800-factory";
    };
  };
}
