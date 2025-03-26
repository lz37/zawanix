{ pkgs, ... }:
{
  imports = [
    ./default
  ];
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode;
  };
}
