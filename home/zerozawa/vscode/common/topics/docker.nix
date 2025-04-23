{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-azuretools.vscode-docker"
  ];
  settings = {
    "[dockercompose]" = {
      "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
    };
  };
}
