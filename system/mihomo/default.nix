{
  config,
  pkgs,
  lib,
  colorsh,
  ...
}: let
  mihomoConfig = config.zerozawa.mihomo;
  zerotier = config.zerozawa.zerotier;
  external-controller = "127.0.0.1:9090";
  proxyProvidersFile = pkgs.writeText "mihomo-proxy-providers.json" (
    builtins.toJSON mihomoConfig.proxy-providers
  );
  proxyProviderPrefixesFile = pkgs.writeText "mihomo-proxy-provider-prefixes.json" (
    builtins.toJSON {
      xingyun = "xy";
    }
  );
  routeExcludeAddressFile = pkgs.writeText "mihomo-route-exclude-address.json" (
    builtins.toJSON [zerotier.netmask]
  );
  configFile = pkgs.runCommand "mihomo.yaml" {} ''
    ${lib.getExe pkgs.yq-go} -oy '
      . as $cfg
      | load("${proxyProviderPrefixesFile}") as $prefixes
      | ."proxy-providers" = (
          load("${proxyProvidersFile}")
          | with_entries(
              . as $provider
              | .value = (
                  $cfg."proxy-providers-common"
                  * {
                    "url": $provider.value,
                    "override": {
                      "additional-prefix": ($prefixes[$provider.key] // $provider.key)
                    }
                  }
                )
            )
        )
      | .tun."route-exclude-address" = load("${routeExcludeAddressFile}")
    ' ${./mihomo.yaml} > "$out"
  '';
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
  };
in
  lib.mkIf config.zerozawa.away-from-home {
    environment.systemPackages = with mihomo; [
      tun.on
      tun.off
    ];
    services.mihomo = {
      package = pkgs.nur.repos.zerozawa.mihomo-smart;
      tunMode = true;
      processesInfo = true;
      enable = true;
      webui = pkgs.metacubexd;
      inherit configFile;
    };
  }
