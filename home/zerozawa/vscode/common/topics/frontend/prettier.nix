{ pkgs, commonVSCVars, ... }:
let
  prettierExtStr = commonVSCVars.prettierExtStr;
in
{
  extensions = with pkgs.vscode-marketplace; [
    esbenp.prettier-vscode
  ];
  settings = {
    "editor.defaultFormatter" = prettierExtStr;
  };
}
