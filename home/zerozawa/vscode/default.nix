{ pkgs-master, ... }:
{
  imports = [
    ./default
  ];
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs-master.vscode;
  };
}
