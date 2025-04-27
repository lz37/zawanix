{
  lib,
  config,
  pkgs,
  ...
}:
let
  fonts-dir = "${config.xdg.dataHome}/fonts";
in

{
  home.activation.install-fonts = lib.hm.dag.entryAfter [ "installPackages" ] ''
    if [ -d "${fonts-dir}" ]; then
      ${pkgs.coreutils}/bin/rm -rf ${fonts-dir}
    fi
    ${pkgs.coreutils}/bin/mkdir -p ${fonts-dir}
    ${pkgs.coreutils}/bin/cp /run/current-system/sw/share/X11/fonts/* ${fonts-dir}/
  '';
}
