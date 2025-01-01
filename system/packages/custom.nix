{
  pkgs,
  config,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "updatenixos" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.nix}/bin/nix flake update --flake ${config.zerozawa.nixos.path.rootRefrence}
      sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --impure
    '')
  ];
}
