{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-azuretools.vscode-containers"
    "docker.docker"
  ];
  settings = {
    # "[dockercompose]" = {
    #   "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
    # };
  };
}
