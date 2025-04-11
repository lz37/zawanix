{ pkgs, ... }:

let
  sddm-eucalyptus-drop = pkgs.kdePackages.callPackage ./sddm-eucalyptus-drop.nix { };
in
{
  environment.systemPackages = [ sddm-eucalyptus-drop.package ];
  services.displayManager = {
    defaultSession = "plasma";
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
      autoNumlock = true;
      enableHidpi = true;
      theme = sddm-eucalyptus-drop.pname;
    };
  };

}
