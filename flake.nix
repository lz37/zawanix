{
  description = "config of zerozawa's nix dev server";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-teleport.url = "github:NixOS/nixpkgs/67d2b8200c828903b36a6dd0fb952fe424aa0606"; # 17.4.2
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nur = {
      url = "github:nix-community/NUR";
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
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix2container = {
      url = "github:nlewo/nix2container";
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
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
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
        let
          inherit (((import ./options) { inherit lib; }).config.zerozawa.path) cfgRoot;
        in
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
                        ./options
                        {
                          nixpkgs = {
                            config = {
                              allowUnfree = true;
                            };
                            overlays = [
                              inputs.nix4vscode.overlays.forVscode
                              (final: prev: {
                                # 启用 NUR
                                nur = import inputs.nur {
                                  nurpkgs = prev;
                                  pkgs = prev;
                                };
                                stable = import inputs.nixpkgs-stable {
                                  inherit system;
                                  config.allowUnfree = true;
                                };
                              })
                              inputs.nix-alien.overlays.default
                            ];
                          };
                        }
                        inputs.nix-flatpak.nixosModules.nix-flatpak
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
                          home-manager.useGlobalPkgs = true;
                          home-manager.useUserPackages = true;
                          home-manager.sharedModules = [
                            inputs.plasma-manager.homeManagerModules.plasma-manager
                            inputs.vscode-server.homeModules.default
                            ./options
                          ];
                          home-manager.users.zerozawa = import ./home/zerozawa;
                          home-manager.extraSpecialArgs = specialArgs;
                        }
                      ]
                      ++ extraModules;
                  };
              in
              {
                zawanix-work = lib.nixosSystem (mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  useTmpfs = true;
                  hostName = "zawanix-work";
                  ram = 32 * 1024;
                });
                zawanix-glap = lib.nixosSystem (mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  isNvidiaGPU = true;
                  useTmpfs = false;
                  hostName = "zawanix-glap";
                  ram = 16 * 1024;
                });
              };
          };
          devShells.default = (
            pkgs.mkShell {
              shellHook =
                let
                  vscodeDir = "${cfgRoot}/.vscode";
                  fmt = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
                in
                ''
                  ${config.nix-health.outputs.devShell.shellHook}
                  ${config.pre-commit.installationScript}
                  if [ ! -d "${vscodeDir}" ]; then
                    ${pkgs.coreutils}/bin/mkdir ${vscodeDir}
                  fi
                  ${pkgs.coreutils}/bin/echo '${
                    builtins.toJSON {
                      "nix.enableLanguageServer" = true;
                      "nix.serverPath" = "${inputs.nil.outputs.packages.${system}.nil}/bin/nil";
                      # "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
                      "nix.serverSettings" = {
                        "nil" = {
                          "formatting" = {
                            "command" = [ fmt ];
                          };
                          "maxMemoryMB" = 4096;
                          "nix" = {
                            "autoArchive" = true;
                            "autoEvalInputs" = true;
                            "nixpkgsInputName" = "nixpkgs";
                          };
                        };
                        "nixd" = {
                          "nixpkgs" = {
                            "expr" = "import (builtins.getFlake \"${cfgRoot}\").inputs.nixpkgs { }";
                          };
                          "formatting" = {
                            # Which command you would like to do formatting
                            "command" = [ fmt ];
                          };
                          "options" = {
                            # Map of eval information
                            # If this is omitted, default search path (<nixpkgs>) will be used.
                            "nixos" = {
                              # This name "nixos" could be arbitrary.
                              # The expression to eval, interpret it as option declarations.
                              "expr" =
                                "(builtins.getFlake \"${cfgRoot}\").legacyPackages.${system}.nixosConfigurations.${lib.trim (builtins.readFile /etc/hostname)}.options";
                            };
                            "flake-parts" = {
                              "expr" = "(builtins.getFlake \"${cfgRoot}\").debug.options";
                            };
                          };
                        };
                      };
                    }
                  }' > ${vscodeDir}/settings.json
                '';
              packages = with pkgs; [
                nix-health
              ];
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
