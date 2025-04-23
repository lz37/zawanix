{ pkgs, commonVSCVars, ... }:
let
  prettierExtStr = commonVSCVars.prettierExtStr;
in
{
  extensions = pkgs.nix4vscode.forVscode [
    "esbenp.prettier-vscode"
  ];
  settings = {
    "editor.defaultFormatter" = prettierExtStr;
  };
}
