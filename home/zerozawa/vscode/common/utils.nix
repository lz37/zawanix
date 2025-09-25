let
  merge-vscode-modules = input: vscode-modules: let
    recursiveUpdateList = attrList: input.lib.foldl' (acc: item: input.lib.recursiveUpdate acc item) {} attrList;
    returns-fallback =
      builtins.map (vscode-module: (vscode-module input)) vscode-modules
      |> builtins.map (
        item:
          recursiveUpdateList [
            {
              keybindings = [];
              settings = {};
              extensions = [];
              globalSnippets = {};
              languageSnippets = {};
              tasks = {
                version = "2.0.0";
              };
              mcp = {};
            }
            item
          ]
      );
  in {
    keybindings = builtins.concatMap (item: item.keybindings) returns-fallback;
    extensions = builtins.concatMap (item: item.extensions) returns-fallback;
    userMcp.servers = recursiveUpdateList (builtins.map (item: item.mcp) returns-fallback);
    userSettings = recursiveUpdateList (
      (builtins.map (item: item.settings) returns-fallback)
      ++ [
        {
          "extensions.experimental.affinity" =
            returns-fallback
            |> input.lib.imap0 (
              i: v:
                v.extensions
                |> input.lib.map (extension: {
                  name = "${extension.vscodeExtPublisher}.${extension.vscodeExtName}";
                  value = i + 1;
                })
                |> builtins.listToAttrs
            )
            |> builtins.zipAttrsWith (name: values: (builtins.elemAt values 0));
        }
      ]
    );
    globalSnippets = recursiveUpdateList (builtins.map (item: item.globalSnippets) returns-fallback);
    languageSnippets = recursiveUpdateList (
      builtins.map (item: item.languageSnippets) returns-fallback
    );
    userTasks = recursiveUpdateList (builtins.map (item: item.tasks) returns-fallback);
  };
in
  merge-vscode-modules
