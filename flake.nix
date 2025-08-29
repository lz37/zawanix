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
    nix-health.url = "github:juspay/nix-health?dir=module";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    stylix.url = "github:danth/stylix/master";
    nvf.url = "github:notashelf/nvf";
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
                    isSSD ? false,
                    extraModules ? [ ],
                    ram ? 8 * 1024,
                    stylixImage,
                  }:
                  let
                    specialArgs = {
                      rootPath = ./.;
                      inherit
                        hostName
                        inputs
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
                  in
                  {
                    inherit system specialArgs;
                    modules =
                      (
                        with inputs.nixos-hardware.nixosModules;
                        [ ]
                        ++ (lib.optional isIntelGPU common-gpu-intel)
                        ++ (lib.optional isIntelCPU common-cpu-intel)
                        ++ (lib.optional (isSSD && !isLaptop) common-pc)
                        ++ (lib.optional (isSSD && isLaptop) common-pc-laptop-ssd)
                      )
                      ++ [
                        ./options
                        (inputs.zerozawa-private + "/default.nix")
                        ./nixpkgs.nix
                        inputs.nix-flatpak.nixosModules.nix-flatpak
                        inputs.nix-index-database.nixosModules.nix-index
                        { programs.nix-index-database.comma.enable = true; }
                        inputs.stylix.nixosModules.stylix
                        ./hardware
                        ./network
                        ./system
                        ./mihomo
                      ]
                      ++ (
                        with inputs.xlibre-overlay.nixosModules;
                        [
                          overlay-xlibre-xserver
                          overlay-all-xlibre-drivers
                        ]
                        ++ (lib.optional isNvidiaGPU nvidia-ignore-ABI)
                      )
                      ++ [
                        inputs.home-manager.nixosModules.home-manager
                        {
                          home-manager = {
                            useGlobalPkgs = false;
                            useUserPackages = true;
                            verbose = true;
                            backupFileExtension = "hm.bak";
                            sharedModules = [
                              inputs.plasma-manager.homeManagerModules.plasma-manager
                              inputs.vscode-server.homeModules.default
                              inputs.stylix.homeModules.stylix
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
              in
              (
                let
                  config = {
                    zawanix-work = mkNixosConfig {
                      isIntelCPU = true;
                      isIntelGPU = true;
                      isSSD = true;
                      hostName = "zawanix-work";
                      ram = 32 * 1024;
                      stylixImage = ./assets/wallpapers/45916741_96947927_p0.jpg;
                    };
                    zawanix-glap = mkNixosConfig {
                      isIntelCPU = true;
                      isIntelGPU = true;
                      isNvidiaGPU = true;
                      isSSD = true;
                      isLaptop = true;
                      hostName = "zawanix-glap";
                      ram = 16 * 1024;
                      stylixImage = ./assets/wallpapers/45916741_96947927_p0.jpg;
                    };
                  };
                in
                {
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
