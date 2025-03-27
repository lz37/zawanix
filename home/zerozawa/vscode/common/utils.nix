input: vscode-modules:
let
  returns = builtins.map (vscode-module: vscode-module input) vscode-modules;
  returns-fallback = builtins.map (
    item:
    {
      keybindings = [ ];
      settings = { };
      extensions = [ ];
      globalSnippets = { };
      languageSnippets = { };
      tasks = [ ];
    }
    // item
  ) returns;
in
{
  keybindings = builtins.concatMap (item: item.keybindings) returns-fallback;
  extensions = builtins.concatMap (item: item.extensions) returns-fallback;
  userSettings = input.lib.mergeAttrsList (builtins.map (item: item.settings) returns-fallback);
  globalSnippets = input.lib.mergeAttrsList (
    builtins.map (item: item.globalSnippets) returns-fallback
  );
  languageSnippets = input.lib.mergeAttrsList (
    builtins.map (item: item.languageSnippets) returns-fallback
  );
  userTasks = {
    version = "2.0.0";
    tasks = builtins.concatMap (item: item.tasks) returns-fallback;
  };
}
