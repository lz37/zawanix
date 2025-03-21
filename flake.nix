{
  description = "config of zerozawa's nix dev server";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hyprland.url = "github:hyprwm/Hyprland";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-master,
      nixpkgs-stable,
      nur,
      nur-xddxdd,
      flake-utils,
      vscode-server,
      home-manager,
      nix-index-database,
      nixos-hardware,
      nix-flatpak,
      nix-alien,
      vscode-extensions,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        hostName = "zawanix";
        pkgs-config = {
          allowUnfree = true;
        };
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config = pkgs-config;
        };
        pkgs-overlays = [
          vscode-extensions.overlays.default
          (final: prev: {
            # 启用 NUR
            nur = import nur {
              nurpkgs = prev;
              pkgs = prev;
              repoOverrides = {
                xddxdd = import nur-xddxdd { pkgs = prev; };
              };
            };
            electron_33-bin = pkgs-stable.electron_33-bin;
            electron_33 = pkgs-stable.electron_33;
          })
          nix-alien.overlays.default
        ];
        pkgs-master = import nixpkgs-master {
          inherit system;
          config = pkgs-config;
          overlays = pkgs-overlays;
        };
      in
      {
        packages = {
          nixosConfigurations.zawanix = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                hostName
                pkgs-master
                pkgs-stable
                ;
            };
            modules = [
              {
                nixpkgs = {
                  config = pkgs-config;
                  overlays = pkgs-overlays;
                };
              }
              nix-flatpak.nixosModules.nix-flatpak
              ./options
              nix-index-database.nixosModules.nix-index
              { programs.nix-index-database.comma.enable = true; }
              vscode-server.nixosModules.default
              (
                { ... }:
                {
                  services.vscode-server.enable = true;
                }
              )
              ./system
              nixos-hardware.nixosModules.common-gpu-intel
              nixos-hardware.nixosModules.common-cpu-intel
              ./hardware-configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.zerozawa = import ./home/zerozawa;
                home-manager.extraSpecialArgs = {
                  inherit
                    inputs
                    hostName
                    pkgs-master
                    pkgs-stable
                    ;
                };
              }
            ];
          };
        };
      }
    );
}
