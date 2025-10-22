{pkgs, ...}: {
  # pkg=pkgs.vscode-selected-extensionsCompatible.open-vsx-release.vadimcn.vscode-lldb;
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    tboox.xmake-vscode
    llvm-vs-code-extensions.vscode-clangd
    xaver.clang-format
    ms-vscode.cpptools
    theqtcompany.qt-core
    theqtcompany.qt-qml
    theqtcompany.qt-ui
    # llvm-vs-code-extensions.lldb-dap
    # vadimcn.vscode-lldb
  ];
  settings = {
    "[cpp]" = {
      "editor.defaultFormatter" = "xaver.clang-format";
    };
  };
}
