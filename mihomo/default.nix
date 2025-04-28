{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "subscribe.mihomo" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.curl}/bin/curl -L -o ${config.zerozawa.path.mihomoCfg} "${config.zerozawa.mihomo.subscribe}"
      ${pkgs.yq}/bin/yq -i '.tun.enable = false' -y ${config.zerozawa.path.mihomoCfg}
      sudo systemctl restart mihomo.service
      NO_FORMAT="\033[0m"
      F_BOLD="\033[1m"
      C_DEEPPINK1="\033[38;5;199m"
      F_UNDERLINED="\033[4m"
      F_DIM="\033[2m"
      C_RED="\033[38;5;9m"
      C_YELLOW2="\033[48;5;190m"
      C_ORANGE1="\033[38;5;214m"
      ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_DEEPPINK1}ご主人様っ''${NO_FORMAT}、''${F_UNDERLINED}''${F_BOLD}''${F_DIM}''${C_RED}''${C_YELLOW2}Tunモード''${NO_FORMAT}停止しちゃいましたぁ''${F_DIM}''${C_ORANGE1}～♪(｡•̀ᴗ-)✧''${NO_FORMAT}"
    '')
  ];
  services.mihomo = {
    package = pkgs.mihomo;
    tunMode = true;
    enable = true;
    webui = pkgs.metacubexd;
    configFile = config.zerozawa.path.mihomoCfg;
  };
}
