{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    redhat.vscode-xml
  ];
  settings = {
    "[xml]" = {
      "editor.defaultFormatter" = "redhat.vscode-xml";
    };
  };
}
