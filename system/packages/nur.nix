{pkgs, ...}: {
  environment.systemPackages = with pkgs.nur.repos; ([
      # pkgs.nogpu.nur.repos.xddxdd.dingtalk
    ]
    ++ (with novel2430; [
      wpsoffice-365
    ])
    ++ (with ccicnce113424; [
      piliplus
    ])
    ++ (with zerozawa; [
      mikusays
      picacg-qt
      JMComic-qt
      wechat-web-devtools-linux
      StartLive
      bilibili_live_tui
      agentic-contract
      (lightnovel-crawler.override {
        calibre = pkgs.nogpu.calibre;
      })
    ]));
}
