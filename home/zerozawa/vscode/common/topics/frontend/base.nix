{ ram, pkgs, ... }:
{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    dbaeumer.vscode-eslint
    stylelint.vscode-stylelint
    formulahendry.auto-rename-tag
    formulahendry.auto-close-tag
    yoavbls.pretty-ts-errors
  ];
  settings = {
    "typescript.tsserver.maxTsServerMemory" = ram / 4;
    "typescript.updateImportsOnFileMove.enabled" = "always";
    "javascript.updateImportsOnFileMove.enabled" = "always";
  };
}
