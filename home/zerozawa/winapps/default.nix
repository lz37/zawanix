{ pkgs, colorsh, ... }:
{
  xdg.configFile = {
    "winapps/winapps.conf" = {
      source = ./winapps.conf;
      force = true;
    };
  };

  home.packages = [
    (pkgs.writeScriptBin "winapps.on" ''
      #!${pkgs.bash}/bin/bash
      systemctl --user start podman-winapps.service
      ${pkgs.coreutils}/bin/echo -e "${
        colorsh.utils.chunibyo.gothic.kaomoji.unicode {
          gothic = "𝔴𝔦𝔫𝔞𝔭𝔭𝔰";
          scope = "魔導鏡";
          action = "幻視界起動";
          kaomoji = "(ﾟ▽ﾟ)ﾉ☆彡";
        }
      }"
    '')
    (pkgs.writeScriptBin "winapps.off" ''
      #!${pkgs.bash}/bin/bash
      systemctl --user stop podman-winapps.service
      ${pkgs.coreutils}/bin/echo -e "${
        colorsh.utils.chunibyo.gothic.kaomoji.unicode {
          gothic = "𝔴𝔦𝔫𝔞𝔭𝔭𝔰";
          scope = "幻視界";
          action = "深淵封印";
          kaomoji = "( ´Д\\`)ﾉ≡";
          unicode = "🔪✨";
        }
      }"
    '')
  ];
}
