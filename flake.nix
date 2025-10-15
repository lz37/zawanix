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
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
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
      url = "github:danth/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
        flake-parts.follows = "flake-parts";
      };
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    zerozawa-private = {
      url = "git+file:/etc/nixos/private?shallow=1&ref=main";
      flake = false;
    };
    hyprland-virtual-desktops = {
      url = "github:levnikmyskin/hyprland-virtual-desktops";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xlibre-overlay = {
      url = "git+https://codeberg.org/takagemacoed/xlibre-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-cli.url = "github:nix-community/nixos-cli";
    waylrc = {
      url = "github:lz37/waylrc/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # inputs.hyprland.follows = "hyprland";
      };
    };
    zerozawa-nur = {
      url = "git+file:/etc/nixos/nur?shallow=1&ref=main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix_version_search_cli.url = "github:jeff-hykin/nix_version_search_cli";
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
            mkNixosConfig = {
              hostName,
              isNvidiaGPU ? false,
              isIntelGPU ? false,
              isIntelCPU ? false,
              isAmdGPU ? false,
              isVM ? false,
              isLaptop ? false,
              isSSD ? false,
              extraModules ? [],
              ram ? 8 * 1024,
              stylixImage,
            }: let
              facterJson = inputs.zerozawa-private + "/facters/${hostName}.json";
              facter = builtins.fromJSON (builtins.readFile facterJson);
              specialArgs = {
                rootPath = ./.;
                inherit
                  hostName
                  inputs
                  facter
                  isNvidiaGPU
                  isIntelCPU
                  isIntelGPU
                  isAmdGPU
                  isVM
                  isLaptop
                  isSSD
                  ram
                  stylixImage
                  colorsh
                  system
                  ;
              };
            in {
              inherit system specialArgs;
              modules =
                [
                  inputs.nixos-facter-modules.nixosModules.facter
                  {config.facter.reportPath = facterJson;}
                ]
                ++ (
                  with inputs.nixos-hardware.nixosModules;
                    []
                    ++ (lib.optional isIntelGPU common-gpu-intel)
                    ++ (lib.optional isIntelCPU common-cpu-intel)
                    ++ (lib.optional (isSSD && !isLaptop) common-pc)
                    ++ (lib.optional (isSSD && isLaptop) common-pc-laptop-ssd)
                )
                ++ (
                  with inputs.xlibre-overlay.nixosModules;
                    [
                      overlay-xlibre-xserver
                      overlay-all-xlibre-drivers
                    ]
                    ++ (lib.optional isNvidiaGPU nvidia-ignore-ABI)
                )
                ++ [
                  ./options
                  (inputs.zerozawa-private + "/default.nix")
                  ./nixpkgs.nix
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.nix-index-database.nixosModules.nix-index
                  {programs.nix-index-database.comma.enable = true;}
                  inputs.chaotic.nixosModules.default
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
                        inputs.chaotic.homeManagerModules.default
                        inputs.plasma-manager.homeModules.plasma-manager
                        inputs.vscode-server.homeModules.default
                        inputs.nvf.homeManagerModules.default
                        ./options
                        (inputs.zerozawa-private + "/default.nix")
                        ./nixpkgs.nix
                      ];
                      users.zerozawa = import ./home/zerozawa;
                      extraSpecialArgs = specialArgs;
                    };
                  }
                ]
                ++ extraModules;
            };
          in (
            let
              config = {
                zawanix-work = mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  isSSD = true;
                  hostName = "zawanix-work";
                  ram = 32 * 1024;
                  stylixImage = ./assets/wallpapers/30837811_94573417_p0.jpg;
                };
                zawanix-glap = mkNixosConfig {
                  isIntelCPU = true;
                  isIntelGPU = true;
                  isNvidiaGPU = true;
                  isSSD = true;
                  isLaptop = true;
                  hostName = "zawanix-glap";
                  ram = 16 * 1024;
                  stylixImage = ./assets/wallpapers/30837811_94573417_p0.jpg;
                };
              };
            in {
              zawanix-work = lib.nixosSystem config.zawanix-work;
              zawanix-glap = lib.nixosSystem config.zawanix-glap;
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
