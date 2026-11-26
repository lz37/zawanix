{
  config,
  pkgs,
  lib,
  colorsh,
  ...
}:
let
  mihomoConfig = config.zerozawa.mihomo;
  external-controller = "127.0.0.1:9090";

  # The overlay is a standard RFC 6902 JSON Patch document (written as YAML for
  # readability). It carries every secret: provider URLs/tokens, landing node
  # credentials, host-specific tun routes.
  patchFile =
    if mihomoConfig.patch-file == null then
      pkgs.writeText "mihomo-patch-empty.yaml" "[]\n"
    else
      mihomoConfig.patch-file;

  configFile = pkgs.runCommand "mihomo.yaml" { } ''
    ${lib.getExe pkgs.yq-go} -o=json ${./mihomo.yaml} > base.json
    ${lib.getExe pkgs.yq-go} -o=json ${patchFile} > patch.json
    ${lib.getExe pkgs.json-patch} -p patch.json < base.json > patched.json
    ${lib.getExe pkgs.yq-go} -P patched.json > $out
  '';

  tunChanger = enable: /* bash */ ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.curl}/bin/curl -H "Content-Type: application/json" -X PATCH -d '{"tun":{"enable":${lib.boolToString enable}}}' http://${external-controller}/configs

    ${pkgs.coreutils}/bin/echo -e "${
      colorsh.utils.chunibyo.gothic.kaomoji.unicode {
        gothic = "𝔪𝔦𝔥𝔬𝔪𝔬";
        scope = if enable then "霊子通路" else "虚数回廊";
        action = if enable then "次元門展開" else "強制封印";
        kaomoji = if enable then "( *¯ ³¯*)♡" else "( ´Д\`)ﾉ≡";
        unicode = if enable then "🌀" else "💢🔒";
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
