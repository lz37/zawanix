{
  description = "config of zerozawa's nix dev server";
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
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
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
      chaotic,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        nixosConfigurations.nixserver = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self;
          };
          modules = [
            {
              nixpkgs.overlays = [
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
            }
            chaotic.nixosModules.default
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
