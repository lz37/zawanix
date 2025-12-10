{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    redhat.java
    vscjava.vscode-gradle
    vscjava.vscode-maven
    vscjava.vscode-java-test
    vscjava.vscode-java-debug
    vscjava.vscode-java-dependency
  ];
  settings = {
  };
}
