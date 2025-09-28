{
  pkgs,
  config,
  ...
}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    leetcode.vscode-leetcode
  ];
  settings = {
    "leetcode.endpoint" = "leetcode-cn";
    "leetcode.workspaceFolder" = "${config.home.homeDirectory}/leetcode/src";
    "leetcode.defaultLanguage" = "cpp";
  };
}
