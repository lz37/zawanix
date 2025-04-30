{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
  environment.systemPackages = with pkgs.nur.repos; [
    # novel2430.wemeet-bin-bwrap-wayland-screenshare
    # linyinfeng.wemeet
    novel2430.wechat-universal-bwrap
    novel2430.wpsoffice-365
    xddxdd.bilibili
    xddxdd.dingtalk
    # xddxdd.piliplus
  ];

}
