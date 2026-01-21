{
  pkgs,
  lib,
  system,
  ...
}:
with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; {
  extensions = [
    redhat.vscode-xml
  ];
  settings = {
    "[xml]" = {
      "editor.defaultFormatter" = "redhat.vscode-xml";
    };
    "xml.server.binary.trustedHashes" = [
      (lib.head (lib.splitString " " (lib.readFile
        "${redhat.vscode-xml}/share/vscode/extensions/redhat.vscode-xml/server/lemminx-linux-${
          if lib.hasPrefix "x86_64" system
          then "x86_64"
          else "unknown"
        }.sha256")))
    ];
  };
}
