{ ram, pkgs, ... }:
{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-edgedevtools.vscode-edge-devtools"
    "dbaeumer.vscode-eslint"
    "stylelint.vscode-stylelint"
    "formulahendry.auto-rename-tag"
    "formulahendry.auto-close-tag"
  ];
  settings = {
    "typescript.tsserver.maxTsServerMemory" = ram / 4;
    "typescript.updateImportsOnFileMove.enabled" = "always";
    "javascript.updateImportsOnFileMove.enabled" = "always";
  };
}
