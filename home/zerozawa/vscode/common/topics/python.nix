{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-python.python
    ms-python.black-formatter
  ];
  settings = {
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.formatOnType" = true;
    };
  };
}
