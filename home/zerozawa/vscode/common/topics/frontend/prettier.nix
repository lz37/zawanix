{ pkgs, ... }:
let
  prettierExtStr = (import ../../common.nix).prettierExtStr;
in
{
  extensions = with pkgs.vscode-marketplace; [
    esbenp.prettier-vscode
  ];
  settings = {
    "editor.defaultFormatter" = prettierExtStr;
  };
}
