{ pkgs, ... }:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-ceintl.vscode-language-pack-zh-hans
  ];
}
