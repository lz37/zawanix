{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-ceintl.vscode-language-pack-zh-hans"
  ];
}
