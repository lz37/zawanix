{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace.theqtcompany; [
    qt-core
    qt-qml
    qt-ui
  ];
}
