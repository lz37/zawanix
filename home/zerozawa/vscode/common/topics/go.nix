{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "golang.go"
  ];
  settings = {
    "go.toolsManagement.autoUpdate" = true;
  };
}
