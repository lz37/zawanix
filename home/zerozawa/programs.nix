{
  config,
  pkgs,
  osConfig,
  ...
}: let
  hostName = osConfig.networking.hostName;
in {
  services = {
    mpris-proxy.enable = true;
  };
  stylix.targets.fish.enable = true;
  programs = {
    nix-monitor = {
      enable = true;
      # Required: customize for your setup
      rebuildCommand = [
        "bash"
        "-c"
        "nixos-rebuild switch --flake /etc/nixos#${hostName} --keep-going --fallback --sudo 2>&1"
      ];
    };
    cargo = {
      enable = true;
      settings = {
        source = {
          crates-io.replace-with = "ustc";
          ustc.registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/";
        };
        registries = {
          ustc.index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/";
        };
      };
    };
    nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;
      settings = {
        indexes = [
          "nixpkgs"
          "home-manager"
          "nixos"
          "nur"
        ];
        experimental = {
          render_docs_indexes = {
            # nvf = "https://notashelf.github.io/nvf/options.html";
            plasma-manager = "https://nix-community.github.io/plasma-manager/options.xhtml";
          };
        };
      };
    };
    television = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    gh = {
      gitCredentialHelper.enable = true;
      enable = true;
      extensions = with pkgs; [
        gh-eco
        gh-s
        gh-i
        gh-notify
        gh-actions-cache
        gh-markdown-preview
        gh-do
      ];
    };
    gh-dash = {
      enable = true;
    };
    pay-respects = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--alias"
        "fk"
      ];
    };
    bash.enable = true;
    fish = {
      enable = true;
    };
    command-not-found.enable = false;
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = config.zerozawa.atuin.server;
        search_mode = "prefix";
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      config = {
        whitelist.prefix = [config.zerozawa.path.code];
      };
      nix-direnv.enable = true;
    };
    ripgrep-all = {
      enable = true;
    };
    ripgrep = {
      enable = true;
    };
  };
}
