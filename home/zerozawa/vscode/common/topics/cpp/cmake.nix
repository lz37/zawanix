{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-vscode.cmake-tools
    twxs.cmake
  ];
}
