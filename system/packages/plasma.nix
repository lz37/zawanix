{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs.kdePackages; [
    yakuake
  ];
}
