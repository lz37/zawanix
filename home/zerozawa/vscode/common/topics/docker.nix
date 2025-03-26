{ pkgs, ... }:

{
  extensions = with pkgs.vscode-extensions; [
    ms-azuretools.vscode-docker
  ];
  settings = {
    "[dockercompose]" = {
      "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
    };
  };
}
