{pkgs, ...}: {
  environment.systemPackages = with pkgs.nur.repos; ((with xddxdd; [
      dingtalk
      # piliplus
    ])
    ++ (with novel2430; [
      wpsoffice-365
      # wechat-universal-bwrap
      # wemeet-bin-bwrap-wayland-screenshare
    ])
    ++ (with zerozawa; [
      mikusays
      picacg-qt
      JMComic-qt
      wechat-web-devtools-linux
    ]));
}
