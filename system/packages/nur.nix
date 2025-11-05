{pkgs, ...}: {
  environment.systemPackages = with pkgs.nur.repos; ((with xddxdd; [
      dingtalk
    ])
    ++ (with novel2430; [
      wpsoffice-365
    ])
    ++ (with zerozawa; [
      mikusays
      picacg-qt
      JMComic-qt
      wechat-web-devtools-linux
    ]));
}
