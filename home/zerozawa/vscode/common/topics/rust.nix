{ pkgs, ... }:

{
  extensions = (
    with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace;
    [
      fill-labs.dependi
      rust-lang.rust-analyzer
      dustypomerleau.rust-syntax
      llvm-vs-code-extensions.lldb-dap
    ]
  );
  settings = {
    "[rust]" = {
      "editor.defaultFormatter" = "rust-lang.rust-analyzer";
    };
  };
}
