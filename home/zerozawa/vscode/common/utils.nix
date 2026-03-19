let
  merge-vscode-modules = input: vscode-modules: let
    recursiveUpdateList = attrList: input.lib.foldl' (acc: item: input.lib.recursiveUpdate acc item) {} attrList;
    returns-fallback =
      map (vscode-module: (vscode-module input)) vscode-modules
      |> map (
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
    enableMcpIntegration = true;
    keybindings = builtins.concatMap (item: item.keybindings) returns-fallback;
    extensions = builtins.concatMap (item: item.extensions) returns-fallback;
    userMcp.servers = recursiveUpdateList (map (item: item.mcp) returns-fallback);
    userSettings = recursiveUpdateList (
      (map (item: item.settings) returns-fallback)
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
    globalSnippets = recursiveUpdateList (map (item: item.globalSnippets) returns-fallback);
    languageSnippets = recursiveUpdateList (
      map (item: item.languageSnippets) returns-fallback
    );
    userTasks = recursiveUpdateList (map (item: item.tasks) returns-fallback);
  };
in
  merge-vscode-modules
