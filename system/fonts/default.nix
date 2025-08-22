# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  # fonts
  fonts = {
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      cache32Bit = true;
      defaultFonts = {
        emoji = [ "Twitter Color Emoji" ];
        monospace = [ "meslo-lgs-nf" ];
        sansSerif = [ "Source Han Sans SC" ];
        # steam
        serif = [ "WenQuanYi Zen Hei" ];
      };
    };
    enableDefaultPackages = true;
    packages =
      (with pkgs; [
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
        montserrat
        nur.repos.novel2430.latex-chinese-fonts
        # nur.repos.chillcicada.ttf-ms-win10-sc-sup
        nur.repos.mikilio.ttf-ms-fonts
        winePackages.fonts
        lxgw-wenkai
        lxgw-neoxihei
        lxgw-fusionkai
        lxgw-wenkai-screen
        fantasque-sans-mono
        unifont
        unifont-csur
        unifont_upper
        (google-fonts.override {
          fonts = [
            # Sans
            "Gabarito"
            "Lexend"
            # Serif
            "Chakra Petch"
            "Crimson Text"
          ];
        })
      ])
      ++ (with pkgs.nerd-fonts; [
        fira-code
        jetbrains-mono
        caskaydia-cove
        caskaydia-mono
        mononoki
        space-mono
        meslo-lg
      ]);
  };
}
