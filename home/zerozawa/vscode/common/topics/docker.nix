{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-azuretools.vscode-containers
    docker.docker
  ];
  settings = {
    "[dockercompose]" = {
      "editor.insertSpaces" = true;
      "editor.tabSize" = 2;
      "editor.autoIndent" = "advanced";
      "editor.quickSuggestions" = {
        "other" = true;
        "comments" = false;
        "strings" = true;
      };
      "editor.defaultFormatter" = "redhat.vscode-yaml";
    };
  };
}
