# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  i18n = rec {
    # Select internationalisation properties.
    defaultLocale = "zh_CN.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
      LC_ALL = defaultLocale;
      LANGUAGE = "zh_CN:zh:en_US:en";
    };
  };

  # fonts
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
    fontconfig = {
      defaultFonts = {
        emoji = [ "Twitter Color Emoji" ];
        monospace = [ "meslo-lgs-nf" ];
        sansSerif = [ "Source Han Sans SC" ];
        # steam
        serif = [ "WenQuanYi Zen Hei" ];
      };
    };
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      plasma6Support = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-lua
      ];
    };
  };

}
