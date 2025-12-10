{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    fwcd.kotlin
    mathiasfrohlich.kotlin
  ];
  settings = {
  };
}
