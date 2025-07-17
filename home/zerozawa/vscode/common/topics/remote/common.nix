{
  pkgs,
  ...
}:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-vscode.remote-explorer
  ];
}
