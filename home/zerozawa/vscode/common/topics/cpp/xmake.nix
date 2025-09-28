{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    tboox.xmake-vscode
    llvm-vs-code-extensions.vscode-clangd
    vadimcn.vscode-lldb
    xaver.clang-format
    # ms-vscode.cpptools
  ];
  settings = {
    "[cpp]" = {
      "editor.defaultFormatter" = "xaver.clang-format";
    };
  };
}
