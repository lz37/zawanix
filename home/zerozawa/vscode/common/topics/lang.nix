{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscodeVersionPrerelease pkgs.vscode-selected.version [
    "ms-ceintl.vscode-language-pack-zh-hans"
  ];
}
