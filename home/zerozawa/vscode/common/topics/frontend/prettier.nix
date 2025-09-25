{
  pkgs,
  commonVSCVars,
  ...
}: let
  prettierExtStr = commonVSCVars.prettierExtStr;
in {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    esbenp.prettier-vscode
  ];
  settings = {
    "editor.defaultFormatter" = prettierExtStr;
  };
}
