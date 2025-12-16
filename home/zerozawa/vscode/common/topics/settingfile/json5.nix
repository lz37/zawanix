{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    savh.json5-kit
  ];
}
