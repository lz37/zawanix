{
  config,
  pkgs,
  lib,
  isLaptop,
  ...
}:
let
  color = (import ../common/color.sh.nix);
  external-controller = "127.0.0.1:9090";
  tunChanger = enable: ''
    #!${pkgs.bash}/bin/bash
    ${color.sh}
    ${pkgs.curl}/bin/curl -H "Content-Type: application/json" -X PATCH -d '{"tun":{"enable":${lib.boolToString enable}}}' http://${external-controller}/configs
    ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_GOLD3}𝔪𝔦𝔥𝔬𝔪𝔬''${NO_FORMAT}${
      if enable then
        ''
          ''${F_UNDERLINED}''${C_MAGENTA3}霊子通路''${NO_FORMAT}・''${F_BOLD}''${C_DODGERBLUE1}次元門展開！''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}( *¯ ³¯*)♡🌀''${NO_FORMAT}
        ''
      else
        ''
          ''${F_UNDERLINED}''${C_MAGENTA3}虚数回廊''${NO_FORMAT}・''${F_BOLD}''${C_DODGERBLUE1}強制封印！''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}( ´Д\`)ﾉ≡💢🔒''${NO_FORMAT}
        ''
    }"
  '';

  mihomo = {
    tun.open = (pkgs.writeScriptBin "mihomo.tun.open" (tunChanger true));
    tun.close = (pkgs.writeScriptBin "mihomo.tun.close" (tunChanger false));
    subscribe = (
      pkgs.writeScriptBin "mihomo.subscribe" ''
        #!${pkgs.bash}/bin/bash
        ${color.sh}
        ${pkgs.curl}/bin/curl -L -o ${config.zerozawa.path.mihomoCfg} "${config.zerozawa.mihomo.subscribe}"
        ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_GOLD3}𝔪𝔦𝔥𝔬𝔪𝔬''${NO_FORMAT}''${F_UNDERLINED}''${C_MAGENTA3}魔導儀式書''${NO_FORMAT}・''${F_BOLD}''${C_DODGERBLUE1}完全降臨！''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}( ✧Д✧)☛✨''${NO_FORMAT}"
        ${pkgs.yq}/bin/yq -i '.tun.enable = false' -y ${config.zerozawa.path.mihomoCfg}
        ${pkgs.yq}/bin/yq -i '."external-controller"="${external-controller}"' -y ${config.zerozawa.path.mihomoCfg}
        ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_GOLD3}𝔪𝔦𝔥𝔬𝔪𝔬''${NO_FORMAT}''${F_UNDERLINED}''${C_MAGENTA3}禁忌結界''${NO_FORMAT}・''${F_BOLD}''${C_DODGERBLUE1}再構成完了！''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}(‘∇’)ﾉ⌒☆爆''${NO_FORMAT}"
        sudo systemctl restart mihomo.service
        ${pkgs.coreutils}/bin/echo -e "''${F_BOLD}''${C_GOLD3}𝔪𝔦𝔥𝔬𝔪𝔬''${NO_FORMAT}''${F_UNDERLINED}''${C_MAGENTA3}蘇生儀式''${NO_FORMAT}・''${F_BOLD}''${C_DODGERBLUE1}全霊展開！''${NO_FORMAT}''${F_DIM}''${C_ORANGE1}( *´艸\`)ﾉ≡▦''${NO_FORMAT}"
      ''
    );
  };
in
if isLaptop then
  {
    environment.systemPackages = with mihomo; [
      subscribe
      tun.open
      tun.close
    ];
    services.mihomo = {
      package = pkgs.mihomo;
      tunMode = true;
      enable = true;
      webui = pkgs.zashboard;
      configFile = config.zerozawa.path.mihomoCfg;
    };
  }
else
  { }
