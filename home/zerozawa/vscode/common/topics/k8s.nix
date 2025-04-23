{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-kubernetes-tools.vscode-kubernetes-tools"
  ];
}
