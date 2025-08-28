{ pkgs, ... }:

{
  extensions = pkgs.vscode-selected-extensionsCompatible-nix4vscode.forVscodePrerelease [
    "ms-python.python"
    "ms-python.black-formatter"
  ];
  settings = {
    "[python]" = {
      "editor.defaultFormatter" = "ms-python.black-formatter";
      "editor.formatOnType" = true;
    };
    "python.terminal.activateEnvironment" = false;
    "python.terminal.shellIntegration.enabled" = false;
    "python.terminal.activateEnvInCurrentTerminal" = false;
  };
}
