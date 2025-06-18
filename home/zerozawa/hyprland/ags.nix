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

}
