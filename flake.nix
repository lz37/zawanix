{
  description = "config of zerozawa's nix dev server";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hyprland.url = "github:hyprwm/Hyprland";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      home-manager,
      nixpkgs-stable,
      plasma-manager,
      nix-flatpak,
      nix-index-database,
      vscode-server,
      nix-alien,
      nur-xddxdd,
      nur,
      vscode-extensions,nixos-hardware,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        nixosConfigurations =
          let
            mkNixosConfig =
              {
                hostName,
                isNvidiaGPU ? false,
                isIntelGPU ? false,
                isIntelCPU ? false,
                isAmdGPU ? false,
                isVM ? false,
                useTmpfs ? false,
                extraModules ? [ ],
                ram ? 8 * 1024,
              }:
              let
                specialArgs = {
                  inherit
                    hostName
                    inputs
                    isNvidiaGPU
                    isIntelCPU
                    isIntelGPU
                    isAmdGPU
                    isVM
                    useTmpfs
                    ram
                    ;
                };
              in
              {
                inherit system specialArgs;
                modules =
                  [
                    {
                      nixpkgs = {
                        config = {
                          allowUnfree = true;
                        };
                        overlays = [
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
                            stable = import nixpkgs-stable {
                              inherit system;
                              config.allowUnfree = true;
                            };
                          })
                          nix-alien.overlays.default
                        ];
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
                    ./hardware
                    ./network
                    ./system
                  ]
                  ++ (nixpkgs.lib.optionals isIntelGPU [
                    nixos-hardware.nixosModules.common-gpu-intel
                  ])
                  ++ (nixpkgs.lib.optionals isIntelCPU [
                    nixos-hardware.nixosModules.common-cpu-intel
                  ])
                  ++ [
                    home-manager.nixosModules.home-manager
                    {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                      home-manager.users.zerozawa = import ./home/zerozawa;
                      home-manager.extraSpecialArgs = specialArgs;
                    }
                  ]
                  ++ extraModules;
              };
          in
          {
            zawanix-work = nixpkgs.lib.nixosSystem (mkNixosConfig {
              isIntelCPU = true;
              isIntelGPU = true;
              useTmpfs = true;
              hostName = "zawanix-work";
              ram = 32 * 1024;
            });
            zawanix-glap = nixpkgs.lib.nixosSystem (mkNixosConfig {
              isIntelCPU = true;
              isIntelGPU = true;
              isNvidiaGPU = true;
              useTmpfs = false;
              hostName = "zawanix-glap";
              ram = 16 * 1024;
            });
          };
      };
    });
}
