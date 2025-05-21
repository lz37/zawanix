{
  pkgs,
  ...
}:

{
  virtualisation.waydroid.enable = true;
  environment.systemPackages = [
    pkgs.waydroid-helper
    pkgs.fakeroot # need for waydroid-helper
  ];
}
