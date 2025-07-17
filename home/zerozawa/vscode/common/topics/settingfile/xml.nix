{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    redhat.vscode-xml
  ];
  settings = {
    "[xml]" = {
      "editor.defaultFormatter" = "redhat.vscode-xml";
    };
  };
}
