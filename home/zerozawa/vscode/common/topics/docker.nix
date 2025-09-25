{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-azuretools.vscode-containers
    docker.docker
  ];
  settings = {
    # "[dockercompose]" = {
    #   "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
    # };
  };
}
