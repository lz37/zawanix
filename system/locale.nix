# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  CN = "zh_CN.UTF-8";
in

{
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  # Select internationalisation properties.
  i18n.defaultLocale = CN;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = CN;
    LC_IDENTIFICATION = CN;
    LC_MEASUREMENT = CN;
    LC_MONETARY = CN;
    LC_NAME = CN;
    LC_NUMERIC = CN;
    LC_PAPER = CN;
    LC_TELEPHONE = CN;
    LC_TIME = CN;
  };

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-han-sans
      source-han-serif
      source-han-mono
      source-code-pro
      sarasa-gothic # 更纱黑体
      hack-font
      jetbrains-mono
      ubuntu_font_family
      meslo-lgs-nf # Meslo Nerd Font patched for Powerlevel10k
      wqy_zenhei
      twemoji-color-font
      # microsoft fonts
      corefonts
      vistafonts
      vistafonts-chs
      vistafonts-cht
      gelasio
      comic-relief
      caladea
      carlito
      winePackages.fonts
      wineWowPackages.fonts
      wine64Packages.fonts
      montserrat
    ];
  };
}
