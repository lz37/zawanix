{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "updatenixos" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nix}/bin/nix flake update --flake ${(import ../../options/variable-pub.nix).path.cfgRoot}
      sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --impure --keep-going --fallback
    '')
  ];
}
