{stylixImage, ...}: {
  stylix = {
    enable = true;
    image = stylixImage;
    autoEnable = false;
    enableReleaseChecks = false;
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
