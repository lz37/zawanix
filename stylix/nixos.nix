{pkgs, ...}: {
  stylix = {
    enable = true;
    image = pkgs.nur.repos.zerozawa.lib.fetchPixiv {
      id = 94573417;
      p = 0;
      sha256 = "sha256-zy6lf348KbIQj0A0ZcmaZ1Llgjg8uXHjoRbpVyl9p3I=";
    };
    autoEnable = false;
    #enableReleaseChecks = false;
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
