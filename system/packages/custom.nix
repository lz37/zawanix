{
  pkgs,
  config,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "updatenixos" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nix}/bin/nix flake update --flake ${config.zerozawa.path.cfgRoot}
      ${pkgs.nh}/bin/nh os switch ${config.zerozawa.path.cfgRoot} -- --impure --keep-going --fallback
      NO_FORMAT="\033[0m"
      F_BOLD="\033[1m"
      C_DEEPPINK1="\033[38;5;199m"
      F_DIM="\033[2m"
      C_ORANGE1="\033[38;5;214m"
      F_UNDERLINED="\033[4m"
      C_GREENYELLOW="\033[38;5;154m"
      ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_DEEPPINK1}ご主人様～''${NO_FORMAT}！システムのアップデート、無事終わりましたぁ♪ えへへ、''${F_UNDERLINED}''${C_GREENYELLOW}これで褒めてもらえるかな…？''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}(〃▽〃)''${NO_FORMAT}"
    '')
  ];
}
