{
  config,
  pkgs,
  lib,
  colorsh,
  ...
}: let
  hw = config.zerozawa.hardware;
  external-controller = "127.0.0.1:9090";
  tunChanger = enable: ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.curl}/bin/curl -H "Content-Type: application/json" -X PATCH -d '{"tun":{"enable":${lib.boolToString enable}}}' http://${external-controller}/configs

    ${pkgs.coreutils}/bin/echo -e "${
      colorsh.utils.chunibyo.gothic.kaomoji.unicode {
        gothic = "𝔪𝔦𝔥𝔬𝔪𝔬";
        scope =
          if enable
          then "霊子通路"
          else "虚数回廊";
        action =
          if enable
          then "次元門展開"
          else "強制封印";
        kaomoji =
          if enable
          then "( *¯ ³¯*)♡"
          else "( ´Д\\`)ﾉ≡";
        unicode =
          if enable
          then "🌀"
          else "💢🔒";
      }
    }"
  '';

  mihomo = {
    tun.on = pkgs.writeScriptBin "mihomo.tun.on" (tunChanger true);
    tun.off = pkgs.writeScriptBin "mihomo.tun.off" (tunChanger false);
    subscribe = (
      pkgs.writeScriptBin "mihomo.subscribe" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.curl}/bin/curl -L -o ${config.zerozawa.path.mihomoCfg} "${config.zerozawa.mihomo.subscribe}"

        ${pkgs.coreutils}/bin/echo -e "${
          colorsh.utils.chunibyo.gothic.kaomoji.unicode {
            gothic = "𝔪𝔦𝔥𝔬𝔪𝔬";
            scope = "魔導儀式書";
            action = "完全降臨";
            kaomoji = "( ✧Д✧)☛";
            unicode = "✨";
          }
        }"

        ${pkgs.yq}/bin/yq -i '.tun.enable = false' -y ${config.zerozawa.path.mihomoCfg}
        ${pkgs.yq}/bin/yq -i '."external-controller"="${external-controller}"' -y ${config.zerozawa.path.mihomoCfg}

        ${pkgs.coreutils}/bin/echo -e "${
          colorsh.utils.chunibyo.gothic.kaomoji.unicode {
            gothic = "𝔪𝔦𝔥𝔬𝔪𝔬";
            scope = "禁忌結界";
            action = "再構成完了";
            kaomoji = "(‘∇’)ﾉ⌒☆爆";
          }
        }"

        sudo systemctl restart mihomo.service

        ${pkgs.coreutils}/bin/echo -e "${
          colorsh.utils.chunibyo.gothic.kaomoji.unicode {
            gothic = "𝔪𝔦𝔥𝔬𝔪𝔬";
            scope = "蘇生儀式";
            action = "全霊展開";
            kaomoji = "( *´艸\\`)ﾉ≡▦";
          }
        }"
      ''
    );
  };
in
  lib.mkIf hw.isLaptop {
    environment.systemPackages = with mihomo; [
      subscribe
      tun.on
      tun.off
    ];
    services.mihomo = {
      package = pkgs.nur.repos.zerozawa.mihomo-smart;
      tunMode = true;
      enable = true;
      webui = pkgs.metacubexd;
      configFile = config.zerozawa.path.mihomoCfg;
    };
  }
