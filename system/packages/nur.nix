{ pkgs, ... }:

{
  environment.systemPackages = with pkgs.nur.repos; [
    # novel2430.wemeet-bin-bwrap-wayland-screenshare
    # linyinfeng.wemeet
    # novel2430.wechat-universal-bwrap
    novel2430.wpsoffice-365
    xddxdd.dingtalk
    # xddxdd.piliplus
  ];

}
