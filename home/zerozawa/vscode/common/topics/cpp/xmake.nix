{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    tboox.xmake-vscode
    llvm-vs-code-extensions.vscode-clangd
    vadimcn.vscode-lldb
    ms-vscode.cpptools
  ];
}
