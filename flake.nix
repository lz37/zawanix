{
  description = "config of zerozawa's nix desktop";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-teleport.url = "github:NixOS/nixpkgs/67d2b8200c828903b36a6dd0fb952fe424aa0606"; # 17.4.2
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nil.url = "github:oxalica/nil";
    nix-health.url = "github:juspay/nix-health?dir=module";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    hyprland.url = "github:hyprwm/Hyprland";
    waybar.url = "github:Alexays/Waybar/master";
    ags.url = "github:Aylur/ags";
    anyrun.url = "github:Kirottu/anyrun";
    illogical-impulse.url = "github:bigsaltyfishes/end-4-dots";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      colorsh = (import ./common/color.sh.nix);
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nix-health.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];
      systems = lib.systems.flakeExposed;
      perSystem =
        {
          config,
          # self',
          # inputs',
          pkgs,
          system,
          ...
        }:
        {
          legacyPackages = {
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
                    isLaptop ? false,
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
                        isLaptop
                        ram
                        colorsh
                        system
                        ;
                    };
                  in
                  {
                    inherit system specialArgs;
                    modules = [
                      ./options
                      ./nixpkgs.nix
                      inputs.nix-index-database.nixosModules.nix-index
                      { programs.nix-index-database.comma.enable = true; }
                      ./hardware
                      ./network
                      ./system
                      ./mihomo
                    ]
                    ++ (lib.optionals isIntelGPU [
                      inputs.nixos-hardware.nixosModules.common-gpu-intel
                    ])
                    ++ (lib.optionals isIntelCPU [
                      inputs.nixos-hardware.nixosModules.common-cpu-intel
                    ])
                    ++ [
                      inputs.home-manager.nixosModules.home-manager
                      {
                        home-manager = {
                          useGlobalPkgs = true;
                          useUserPackages = true;
                          sharedModules = [
                            inputs.plasma-manager.homeManagerModules.plasma-manager
                            inputs.vscode-server.homeModules.default
                            ./options
                            inputs.ags.homeManagerModules.default
                          ];
                          users.zerozawa = import ./home/zerozawa;
                          extraSpecialArgs = specialArgs;
                        };
                      }
                    ]
                    ++ extraModules;
                  };
              in
              {
                zawanix-work = lib.nixosSystem (mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  hostName = "zawanix-work";
                  ram = 32 * 1024;
                });
                zawanix-glap = lib.nixosSystem (mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  isNvidiaGPU = true;
                  isLaptop = true;
                  hostName = "zawanix-glap";
                  ram = 16 * 1024;
                });
              };
          };
          devShells.default = (
            pkgs.mkShell {
              shellHook = ''
                ${config.nix-health.outputs.devShell.shellHook}
                ${config.pre-commit.installationScript}
                ${pkgs.coreutils}/bin/echo -e "${
                  colorsh.utils.chunibyo.gothic.kaomoji.unicode {
                    gothic = "𝔡𝔦𝔯𝔢𝔫𝔳";
                    scope = "魔導結界";
                    action = "異空覚醒";
                    kaomoji = "(ﾟ▽ﾟ*)ﾉ⌒☆";
                  }
                }"
              '';
            }
          );
          pre-commit = {
            settings = {
              hooks = {
                treefmt = {
                  enable = true;
                };
              };
            };
          };
          # run by `nix fmt`
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              shellcheck.enable = true;
            };
          };
        };
      flake = {
        nix-health.default = {
          direnv = {
            enable = true;
            required = true;
          };
          system = {
            enable = true;
            min_disk_space = "128.0 GB";
            min_ram = "16.0 GB";
            required = true;
          };
        };
      };
    };
}
