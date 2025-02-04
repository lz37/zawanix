{
  description = "config of zerozawa's nix dev server";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      nur-xddxdd,
      flake-utils,
      vscode-server,
      home-manager,
      nix-index-database,
      nixos-hardware,
      nix-flatpak,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        nixosConfigurations.zawanix = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self;
          };
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            {
              nixpkgs = {
                config.allowUnfree = true;
                overlays = [
                  (final: prev: {
                    # 启用 NUR
                    nur = import nur {
                      nurpkgs = prev;
                      pkgs = prev;
                      repoOverrides = {
                        xddxdd = import nur-xddxdd { pkgs = prev; };
                      };
                    };
                  })
                ];
              };
            }
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
            home-manager.nixosModules.home-manager
            ./system
            nixos-hardware.nixosModules.common-gpu-intel
            nixos-hardware.nixosModules.common-cpu-intel
            ./hardware-configuration.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zerozawa = import ./home/zerozawa;
            }
          ];
        };
      };
    });
}
