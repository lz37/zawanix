{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    golang.go
  ];
  settings = {
    "go.toolsManagement.autoUpdate" = true;
  };
}
