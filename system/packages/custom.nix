{
  pkgs,
  config,
  colorsh,
  ...
}:
let
  zawanix = rec {
    update = pkgs.writeScriptBin "zawanix.update" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nix}/bin/nix flake update --flake ${config.zerozawa.path.cfgRoot}
      ${pkgs.coreutils}/bin/echo -e "${
        colorsh.utils.chunibyo.gothic.kaomoji.unicode {
          gothic = "𝔷𝔞𝔴𝔞𝔫𝔦𝔵";
          scope = "星律鎖";
          action = "位階突破";
          kaomoji = "(✧∇✧)╯";
          unicode = "🌌";
        }
      }"
    '';
    rebuild = pkgs.writeScriptBin "zawanix.rebuild" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nh}/bin/nh os switch ${config.zerozawa.path.cfgRoot} -- --impure --keep-going --fallback
      ${pkgs.coreutils}/bin/echo -e "${
        colorsh.utils.chunibyo.gothic.kaomoji.unicode {
          gothic = "𝔷𝔞𝔴𝔞𝔫𝔦𝔵";
          scope = "魔導構造体";
          action = "魂の再誕";
          kaomoji = "(☄◣∀◢)☄";
          unicode = "💫";
        }
      }"
    '';
    upgrade = pkgs.writeScriptBin "zawanix.upgrade" ''
      #!${pkgs.bash}/bin/bash
      ${update}/bin/zawanix.update
      ${rebuild}/bin/zawanix.rebuild
    '';
    system.packages =
      let
        packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
      pkgs.writeScriptBin "zawanix.system.packages" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.coreutils}/bin/echo -e "${formatted}"
        ${pkgs.coreutils}/bin/echo -e "${
          colorsh.utils.chunibyo.gothic.kaomoji.unicode {
            gothic = "𝔷𝔞𝔴𝔞𝔫𝔦𝔵";
            scope = "魔導枢機院";
            splitter = "";
            action = "に登録された禁術${builtins.toString (builtins.length sortedUnique)}章";
            kaomoji = "(⌒▽⌒)☆";
            unicode = "⚙️🔥";
          }
        }"
      '';
  };
in

{
  environment.systemPackages = with zawanix; [
    update
    rebuild
    upgrade
    system.packages
    (pkgs.callPackage ./build/picacg.nix { }).package
    (pkgs.callPackage ./build/jmcomic.nix { }).package
  ];
}
