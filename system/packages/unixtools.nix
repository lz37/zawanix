{
  pkgs,
  ...
}:

{
  # 遍历 pkgs.unixtools 下的所有包
  environment.systemPackages = builtins.map (name: pkgs.unixtools.${name}) (builtins.attrNames pkgs.unixtools);
}
