{ pkgs, ... }:

{
  nix = {
    settings = {
      # 实验性功能
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        # 中科大
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        # 清华
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        # 北外
        # "https://mirrors.bfsu.edu.cn/nix-channels/store"
        # ISCAS
        # "https://mirror.iscas.ac.cn/nix-channels/store"
        # 上交
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
        # 南大
        # "https://mirror.nju.edu.cn/nix-channels/store"

        "https://cache.nixos.org"

        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://winapps.cachix.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="
      ];
      trusted-users = [
        "zerozawa"
      ];
    };
    # gc
    gc = {
      # programs.nh.clean.enable and nix.gc.automatic are both enabled. Please use one or the other to avoid conflict.
      automatic = false;
      dates = "03:00";
      options = "--delete-older-than 5d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
  };
}
