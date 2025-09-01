{ stylixImage, ... }:
{
  stylix = {
    enable = true;
    image = stylixImage;
    autoEnable = false;
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
