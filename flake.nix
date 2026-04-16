{
  description = "config of zerozawa's nix desktop";
  inputs = {
    nixpkgs.url = "git+https://mirrors.cernet.edu.cn/nixpkgs.git?ref=nixos-unstable&shallow=1";
    nixpkgs-stable.url = "git+https://mirrors.cernet.edu.cn/nixpkgs.git?ref=nixos-25.11&shallow=1";
    nixpkgs-master.url = "git+https://mirrors.cernet.edu.cn/nixpkgs.git?ref=master&shallow=1";
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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nix-health.url = "github:juspay/nix-health?dir=module";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        flake-parts.follows = "flake-parts";
      };
    };
    zerozawa-private = {
      url = "git+ssh://git@github.com/lz37/zawanix-private?ref=main";
      flake = false;
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nixos-cli.url = "github:nix-community/nixos-cli";
    zerozawa-nur = {
      url = "github:lz37/nur/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix_version_search_cli.url = "github:jeff-hykin/nix_version_search_cli";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ast-grep-skill = {
      url = "github:ast-grep/agent-skill";
      flake = false;
    };
    anthropics-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    ai-agent-skills = {
      url = "github:MoizIbnYousaf/Ai-Agent-Skills";
      flake = false;
    };
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    awesome-copilot = {
      url = "github:github/awesome-copilot";
      flake = false;
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs-master";
    };
    nix-monitor.url = "github:antonjah/nix-monitor";
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    colorsh = import ./common/color.sh.nix;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.nix-health.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];
      systems = lib.systems.flakeExposed;
      perSystem = {
        config,
        # self',
        # inputs',
        pkgs,
        system,
        ...
      }: {
        legacyPackages = {
          nixosConfigurations = let
            mkNixosConfig = profile: let
              specialArgs = {
                rootPath = ./.;
                inherit inputs colorsh;
              };
            in {
              inherit system specialArgs;
              modules =
                [
                  ./options
                  profile.hostOptionModule
                  (import (inputs.zerozawa-private + "/default.nix") {
                    hostName = profile.hostName;
                  })
                  ./nixpkgs.nix
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.nix-index-database.nixosModules.nix-index
                  {programs.nix-index-database.comma.enable = true;}
                  inputs.stylix.nixosModules.stylix
                  inputs.nixos-cli.nixosModules.nixos-cli
                  ./stylix/nixos.nix
                  ./hardware
                  ./network
                  ./system
                  ./mihomo
                ]
                ++ [
                  inputs.home-manager.nixosModules.home-manager
                  {
                    home-manager = {
                      useGlobalPkgs = false;
                      useUserPackages = true;
                      verbose = true;
                      backupFileExtension = "hm.bak";
                      sharedModules = [
                        inputs.plasma-manager.homeModules.plasma-manager
                        inputs.vscode-server.homeModules.default
                        ./options
                        (import (inputs.zerozawa-private + "/default.nix") {
                          hostName = profile.hostName;
                        })
                        inputs.dankMaterialShell.homeModules.dank-material-shell
                        inputs.dms-plugin-registry.modules.default
                        inputs.nix-monitor.homeManagerModules.default
                        ./nixpkgs.nix
                      ];
                      users.zerozawa = import ./home/zerozawa;
                      extraSpecialArgs = specialArgs;
                    };
                  }
                ];
            };
          in (
            let
              config = {
                zawanix-work = mkNixosConfig {
                  hostName = "zawanix-work";
                  hostOptionModule = {lib, ...}: {
                    config = {
                      networking.hostName = "zawanix-work";
                      zerozawa.host.isGameMachine = lib.mkForce false;
                    };
                  };
                };
                zawanix-glap = mkNixosConfig {
                  hostName = "zawanix-glap";
                  hostOptionModule = {lib, ...}: {
                    config = {
                      networking.hostName = "zawanix-glap";
                      zerozawa.host.isGameMachine = lib.mkForce true;
                    };
                  };
                };
                zawanix-fubuki = mkNixosConfig {
                  hostName = "zawanix-fubuki";
                  hostOptionModule = {lib, ...}: {
                    config = {
                      networking.hostName = "zawanix-fubuki";
                      zerozawa.host.isGameMachine = lib.mkForce true;
                    };
                  };
                };
              };
            in {
              zawanix-work = lib.nixosSystem config.zawanix-work;
              zawanix-glap = lib.nixosSystem config.zawanix-glap;
              zawanix-fubuki = lib.nixosSystem config.zawanix-fubuki;
            }
          );
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
                packageOverrides.treefmt = pkgs.treefmt;
                settings.formatters = [
                  pkgs.alejandra
                ];
              };
            };
          };
        };
        # run by `nix fmt`
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
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
