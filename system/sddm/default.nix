{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ sddm-eucalyptus-drop ];
  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
      autoNumlock = true;
      enableHidpi = true;
      theme = pkgs.sddm-eucalyptus-drop.pname;
    };
  };

}
