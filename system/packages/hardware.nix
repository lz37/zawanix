{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dmidecode
    vrrtest
    linuxquota
    wirelesstools
  ];
}
