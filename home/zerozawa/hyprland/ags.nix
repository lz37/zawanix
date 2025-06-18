{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    illogical-impulse-ags-launcher
    illogical-impulse-agsPackage
    gradience
  ];

  # AGS Configuration
  home.file.".config/ags" = {
    source = "${pkgs.illogical-impulse-ags}";
    recursive = true;
  };
}
