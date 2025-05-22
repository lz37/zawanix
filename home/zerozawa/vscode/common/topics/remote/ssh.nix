{
  pkgs,
  config,
  lib,
  ...
}:

{
  extensions = pkgs.nix4vscode.forVscode [
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
  ];
  settings = {
    "remote.SSH.remotePlatform" = (
      builtins.zipAttrsWith (key: values: values) (
        lib.map (
          {
            host,
            type,
            ...
          }:
          {
            "${host}" = type;
          }
        ) config.zerozawa.ssh.machines
      )
    );
    "remote.SSH.useLocalServer" = false;
  };
}
