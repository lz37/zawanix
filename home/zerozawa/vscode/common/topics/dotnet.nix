{ pkgs, ... }:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-dotnettools.csdevkit"
    "ms-dotnettools.vscodeintellicode-csharp"
  ];
}
