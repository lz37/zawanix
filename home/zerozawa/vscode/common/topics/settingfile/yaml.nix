{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    redhat.vscode-yaml
  ];
  settings = {
    "[yaml]" = {
      "editor.defaultFormatter" = "redhat.vscode-yaml";
      "editor.tabSize" = 2;
    };
  };
}
