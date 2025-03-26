{ pkgs, ... }:

{
  extensions = with pkgs.vscode-marketplace; [
    tintinweb.vscode-inline-bookmarks
    wakatime.vscode-wakatime
    streetsidesoftware.code-spell-checker
    christian-kohler.path-intellisense
  ];
  settings = {
    "terminal.integrated.defaultProfile.linux" = "zsh";
    "debug.onTaskErrors" = "abort";
    "emmet.includeLanguages" = {
      "javascript" = "javascriptreact";
      "typescript" = "typescriptreact";
    };
    "editor.tabSize" = 2;
    "files.associations" = {
      "*.env.*" = "dotenv";
      "*.json5" = "json";
      "flake.lock" = "json";
    };
    "files.trimTrailingWhitespace" = true;
    "git.openRepositoryInParentFolders" = "never";
    "http.proxySupport" = "on";
    "json.schemaDownload.enable" = true;
    "security.workspace.trust.untrustedFiles" = "open";
    "redhat.telemetry.enabled" = true;
    # @todo add more settings
    "extensions.experimental.affinity" = { };
  };
}
