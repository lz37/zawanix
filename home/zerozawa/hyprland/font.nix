# https://github.com/bigsaltyfishes/end-4-dots/blob/main/modules/packages.nix
{
  pkgs,
  ...
}:
{
  fonts.fontconfig.enable = true;
  home.packages =
    (with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      (google-fonts.override {
        fonts = [
          "Gabarito"
          "Lexend"
          "Chakra Petch"
          "Crimson Text"
          "Alfa Slab One"
        ];
      })
      cascadia-code
      material-symbols
    ])
    ++ (with pkgs.nerd-fonts; [
      # nerd fonts
      ubuntu
      ubuntu-mono
      jetbrains-mono
      caskaydia-cove
      fantasque-sans-mono
      mononoki
      space-mono
    ]);
}
