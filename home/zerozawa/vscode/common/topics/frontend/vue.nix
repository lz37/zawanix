{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    vue.volar
  ];
}
