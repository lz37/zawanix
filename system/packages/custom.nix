{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "updatenixos" ''
      #!${pkgs.bash}/bin/bash
      sudo nixos-rebuild switch
    '')
  ];
}
