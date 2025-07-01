{ pkgs, lib, ... }:

let
  patchDesktop =
    pkg: appName: from: to:
    with pkgs;
    let
      zipped = lib.zipLists from to;
      # 多個要用 sed 執行的操作是用 -e 指定的
      sed-args = builtins.map ({ fst, snd }: "-e 's#${fst}#${snd}#g'") zipped;
      concat-args = builtins.concatStringsSep " " sed-args;
    in
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
        ${coreutils}/bin/mkdir -p $out/share/applications
        ${gnused}/bin/sed ${concat-args} \
         ${pkg}/share/applications/${appName}.desktop \
         > $out/share/applications/${appName}.desktop
      ''
    );
in
patchDesktop
