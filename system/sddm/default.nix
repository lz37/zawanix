{
  pkgs,
  stylixImage,
  hostName,
  config,
  ...
}: let
  theme = pkgs.nur.repos.zerozawa.sddm-eucalyptus-drop.override {
    overrideTheme =
      {
        Background = "${pkgs.lib.cleanSource stylixImage}";
        MainColour = "#${config.lib.stylix.colors.base05}";
        AccentColour = "#${config.lib.stylix.colors.base04}";
        BackgroundColour = "#${config.lib.stylix.colors.base0F}";
        Font = "LXGW WenKai Mono";
        FormPosition = "center";
        BlurRadius = "30";
        FullBlur = "true";
        PartialBlur = "false";
      }
      // (
        {
          zawanix-work = {
            ScreenWidth = "3840";
            ScreenHeight = "2160";
          };
          zawanix-glap = {
            ScreenWidth = "2560";
            ScreenHeight = "1440";
          };
        }
      ."${hostName}"
      );
  };
in {
  environment.systemPackages = [theme];
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
      theme = theme.pname;
    };
  };
}
