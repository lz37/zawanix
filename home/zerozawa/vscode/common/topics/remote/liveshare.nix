{ pkgs, ... }:

{
  extensions = with pkgs.vscode-extensions; [
    ms-vsliveshare.vsliveshare
  ];
}
