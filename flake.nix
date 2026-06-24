{
  description = "config of zerozawa's nix desktop";
  inputs = {
    nixpkgs.url = "git+https://mirrors.cernet.edu.cn/nixpkgs.git?ref=nixos-unstable-small&shallow=1";
    nixpkgs-stable.url = "git+https://mirrors.cernet.edu.cn/nixpkgs.git?ref=nixos-26.05&shallow=1";
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
    mio-nur.url = "github:mio-19/nurpkgs";
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
    nix-monitor.url = "github:antonjah/nix-monitor";
    # opencode = {
    #   url = "github:anomalyco/opencode/dev";
    # };
    # hyprland.url = "github:hyprwm/Hyprland/main";
    # hypr-dynamic-cursors = {
    #   url = "github:VirtCode/hypr-dynamic-cursors";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      flake = false;
    };
    # devenv
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
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
        inputs.devenv.flakeModule
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
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: true;
          overlays = [
            (final: prev: {
              nur = import inputs.nur {
                nurpkgs = prev;
                pkgs = prev;
                repoOverrides = {
                  zerozawa = import inputs.zerozawa-nur {inherit pkgs;};
                };
              };
            })
          ];
        };
        legacyPackages = {
          nixosConfigurations = let
            mkNixosConfig = profile: let
              specialArgs = {
                rootPath = ./.;
                inherit (profile) hostName;
                inherit inputs colorsh;
              };
            in {
              inherit system specialArgs;
              modules =
                [
                  ./options
                  (inputs.zerozawa-private + "/default.nix")
                  ./nixpkgs.nix
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.nix-index-database.nixosModules.nix-index
                  {programs.nix-index-database.comma.enable = true;}
                  inputs.stylix.nixosModules.stylix
                  inputs.nixos-cli.nixosModules.nixos-cli
                  ./stylix/nixos.nix
                  ./network
                  ./hardware
                  ./system
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
                        inputs.dms-plugin-registry.homeModules.default
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
                };
                zawanix-glap = mkNixosConfig {
                  hostName = "zawanix-glap";
                };
                zawanix-fubuki = mkNixosConfig {
                  hostName = "zawanix-fubuki";
                };
                zawanix-thinkbook = mkNixosConfig {
                  hostName = "zawanix-thinkbook";
                };
              };
            in {
              zawanix-work = lib.nixosSystem config.zawanix-work;
              zawanix-glap = lib.nixosSystem config.zawanix-glap;
              zawanix-fubuki = lib.nixosSystem config.zawanix-fubuki;
              zawanix-thinkbook = lib.nixosSystem config.zawanix-thinkbook;
            }
          );
        };
        devenv.shells.default = {
          name = "zawanix";
          packages = with pkgs; [
            lux-cli
          ];
          languages = {
            javascript = {
              enable = true;
              bun = {
                enable = true;
                package =
                  (import inputs.nixpkgs-master {
                    inherit system;
                  }).bun;
                install.enable = true;
              };
            };
            lua = {
              enable = true;
              package = pkgs.lua5_5;
              lsp.enable = true;
            };
          };
          enterShell = ''
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
            # 防止被 node_modules 下覆盖
            export PATH=${pkgs.nur.repos.zerozawa.oh-my-pi}/bin:$PATH
          '';
        };
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
