{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ sddm-eucalyptus-drop ];
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
      theme = pkgs.sddm-eucalyptus-drop.name;
    };
  };

}
