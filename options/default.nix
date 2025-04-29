{ lib, ... }:
let
  mkOptionType =
    type:
    lib.mkOption {
      inherit type;
    };
  str = mkOptionType lib.types.str;
in

{
  # should be --impure
  imports = [
    /etc/nixos/private
  ];
  options = {
    zerozawa = {
      version = {
        nixos = str;
        home-manager-version = str;
      };
      path = {
        cfgRoot = str;
        profile = str;
        p10k = str;
        home = str;
        code = str;
        public = str;
        downloads = str;
        private = str;
        mihomoCfg = str;
        kitty = str;
      };
      users.zerozawa.uid = mkOptionType lib.types.int;
      network = {
        wired-interface = str;
        static-address = str;
      };
      atuin = {
        server = str;
      };
      servers = {
        openwrt = {
          address = str;
        };
      };
      git = {
        userName = str;
        userEmail = str;
      };
      vscode = {
        sherlock.userId = str;
        remote.SSH.remotePlatform = mkOptionType lib.types.raw;
      };
      mihomo = {
        subscribe = str;
      };
    };
  };

  config = {
    zerozawa = rec {
      version = {
        nixos = "25.05";
        home-manager-version = version.nixos;
      };
      path = rec {
        cfgRoot = "/etc/nixos";
        profile = "${cfgRoot}/profile";
        p10k = "${profile}/.p10k.zsh";
        home = "/home/zerozawa";
        code = "${home}/code";
        public = "${home}/Public";
        downloads = "${home}/Downloads";
        private = "${cfgRoot}/private";
        mihomoCfg = "${profile}/mihomo.yaml";
        kitty = "${profile}/kitty.conf";
      };
      users = {
        zerozawa = {
          uid = 1000;
        };
      };
    };
  };
}
