{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-kubernetes-tools.vscode-kubernetes-tools"
  ];
  settings = {
    "vs-kubernetes" = {
      "vs-kubernetes.crd-code-completion" = "enabled";
    };
  };
}
