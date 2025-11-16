{pkgs, ...}: {
  extensions = (
    with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
      rust-lang.rust-analyzer
      dustypomerleau.rust-syntax
      llvm-vs-code-extensions.lldb-dap
      cordx56.rustowl-vscode
    ]
  );
  settings = {
    "[rust]" = {
      "editor.defaultFormatter" = "rust-lang.rust-analyzer";
    };
  };
}
