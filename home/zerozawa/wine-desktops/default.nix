{ pkgs, ... }:

let
  HOME = (import ../../../options/variable-pub.nix).path.home;
in
{
  xdg.dataFile = {
    "applications/wecom.desktop".text = ''
      [Desktop Entry]
      Name=企业微信
      Exec=systemd-run --user -p MemoryMax=256M --scope env WINEPREFIX="${HOME}/.wine" ${pkgs.wineWowPackages.stagingFull}/bin/wine C:\\\\ProgramData\\\\Microsoft\\\\Windows\\\\Start\\ Menu\\\\企业微信.lnk
      Type=Application
      StartupNotify=true
      Path=${HOME}/.wine/dosdevices/c:/Program Files (x86)/WXWork
      Icon=AF03_WXWork.0
      StartupWMClass=wxwork.exe
    '';
  };
}
