{ pkgs, ... }: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    tboox.xmake-vscode
  ];
}
