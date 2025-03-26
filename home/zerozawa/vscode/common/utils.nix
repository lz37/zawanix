input: vscode-modules:
let
  returns = builtins.map (vscode-module: vscode-module input) vscode-modules;
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
  userSettings = input.lib.mergeAttrsList (builtins.map (item: item.settings) returns-fallback);
  enableUpdateCheck = false;
  enableExtensionUpdateCheck = false;
}
