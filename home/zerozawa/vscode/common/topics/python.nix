{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-python.python
    ms-python.pylint
    charliermarsh.ruff
  ];
  settings = {
    "[python]" = {
      "editor.defaultFormatter" = "charliermarsh.ruff";
      "editor.formatOnType" = true;
    };
    "python.terminal.activateEnvironment" = false;
    "python.terminal.shellIntegration.enabled" = false;
    "python.terminal.activateEnvInCurrentTerminal" = false;
  };
}
