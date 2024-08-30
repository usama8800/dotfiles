{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-alien,
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
    };
  };
}
