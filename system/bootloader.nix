{
  pkgs,
  config,
  ...
}: let
  hostName = config.networking.hostName;
in {
  boot.loader = {
    systemd-boot.enable = false;

    grub = {
      enable = true;
      device = "nodev"; # EFI 系统专用
      efiSupport = true; # 启用 EFI 支持
      useOSProber = true; # 检测其他操作系统（如 Windows）
      theme = pkgs.nur.repos.zerozawa.grub-theme-yorha.override {
        resolution =
          {
            zawanix-glap = "2560x1440";
            zawanix-fubuki = "3840x2160";
            zawanix-work = "1920x1080";
          }
          .${
            hostName
          };
      };
    };

    efi.canTouchEfiVariables = true;
    timeout = 2;
  };
}
