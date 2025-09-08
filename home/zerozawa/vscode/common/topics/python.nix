{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-python.python
    ms-python.pylint
  ];
  settings = {
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.pylint";
      "editor.formatOnType" = true;
    };
    "python.terminal.activateEnvironment" = false;
    "python.terminal.shellIntegration.enabled" = false;
    "python.terminal.activateEnvInCurrentTerminal" = false;
  };
}
