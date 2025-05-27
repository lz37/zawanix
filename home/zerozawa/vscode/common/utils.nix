let
  merge-vscode-modules =
    input: vscode-modules:
    let
      recursiveUpdateList =
        attrList: input.lib.foldl' (acc: item: input.lib.recursiveUpdate acc item) { } attrList;
      returns = builtins.map (vscode-module: (vscode-module input)) vscode-modules;
      returns-fallback = builtins.map (
        item:
        recursiveUpdateList [
          {
            keybindings = [ ];
            settings = { };
            extensions = [ ];
            globalSnippets = { };
            languageSnippets = { };
            tasks = {
              version = "2.0.0";
            };
          }
          item
        ]
      ) returns;
    in
    {
      keybindings = builtins.concatMap (item: item.keybindings) returns-fallback;
      # 获取id为(p.vscodeExtPublisher).(p.vscodeExtName)
      extensions = builtins.concatMap (item: item.extensions) returns-fallback;
      userSettings = recursiveUpdateList (builtins.map (item: item.settings) returns-fallback);
      globalSnippets = recursiveUpdateList (builtins.map (item: item.globalSnippets) returns-fallback);
      languageSnippets = recursiveUpdateList (
        builtins.map (item: item.languageSnippets) returns-fallback
      );
      userTasks = recursiveUpdateList (builtins.map (item: item.tasks) returns-fallback);
    };
in
merge-vscode-modules
