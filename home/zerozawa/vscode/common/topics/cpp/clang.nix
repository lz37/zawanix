{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    llvm-vs-code-extensions.vscode-clangd
    xaver.clang-format
  ];
  settings = {
    "[cpp]" = {
      "editor.defaultFormatter" = "xaver.clang-format";
    };
  };
}
