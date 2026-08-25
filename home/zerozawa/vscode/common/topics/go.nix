{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible; (with vscode-marketplace; [
    golang.go
    msyrus.go-doc
  ]);
  settings = {
    "go.toolsManagement.autoUpdate" = true;
    "[go]" = {
      "editor.defaultFormatter" = "golang.go";
    };
  };
}
