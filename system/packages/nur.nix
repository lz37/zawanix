{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "electron-33.4.11"
    "ventoy-1.1.05"
  ];
  environment.systemPackages = with pkgs.nur.repos; [
    # novel2430.wemeet-bin-bwrap-wayland-screenshare
    # linyinfeng.wemeet
    novel2430.wechat-universal-bwrap
    (novel2430.wpsoffice-365.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://wps-linux-365.wpscdn.cn/wps/download/ep/Linux365/20327/wps-office_${old.version}.AK.preload.sw_amd64.deb";
        hash = "sha256-N+2n6i7RCoKjAQ6Pds/dpfupnKR624RUiGj2cQQFpHk=";
        curlOptsList = [ "-ehttps://365.wps.cn" ];
      };
    }))
    xddxdd.dingtalk
    # xddxdd.piliplus
  ];

}
