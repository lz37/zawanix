{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-git;
    installRemoteServer = true;
  };
}
