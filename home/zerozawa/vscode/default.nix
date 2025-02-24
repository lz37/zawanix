{ pkgs-master, ... }:
{
  imports = [
    ./default
  ];
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    package = pkgs-master.vscode;
  };
}
