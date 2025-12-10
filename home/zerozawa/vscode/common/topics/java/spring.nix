{pkgs, ...}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    vscjava.vscode-spring-initializr
    vscjava.vscode-spring-boot-dashboard
    vmware.vscode-spring-boot
  ];
  settings = {
  };
}
