{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "updatenixos" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nix}/bin/nix flake update --flake ${(import ../../options/variable-pub.nix).path.cfgRoot}
      ${pkgs.nh}/bin/nh os switch ${(import ../../options/variable-pub.nix).path.cfgRoot} -- --impure --keep-going --fallback
    '')
  ];
}
