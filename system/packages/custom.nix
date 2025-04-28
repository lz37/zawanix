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
    '')
  ];
}
