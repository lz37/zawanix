{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    ms-kubernetes-tools.vscode-kubernetes-tools
  ];
}
