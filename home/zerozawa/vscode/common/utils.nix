{ lib, ... }@input:
vscode-modules:
let
  returns = builtins.map vscode-modules (vscode-module: vscode-module (input // { inherit lib; }));
  returns-fallback = builtins.map (
    item:
    {
      keybindings = [ ];
      settings = { };
      extensions = [ ];
    }
    // item
  ) returns;
in
{
  keybindings = builtins.concatMap (item: item.keybindings) returns-fallback;
  extensions = builtins.concatMap (item: item.extensions) returns-fallback;
  userSettings = lib.mergeAttrsList (builtins.map (item: item.settings) returns-fallback);
  enableUpdateCheck = false;
  enableExtensionUpdateCheck = false;
}
