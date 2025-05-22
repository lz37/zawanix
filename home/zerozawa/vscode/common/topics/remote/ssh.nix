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
      builtins.listToAttrs (
        lib.map (
          {
            host,
            type,
            ...
          }:
          {
            name = host;
            value = type;
          }
        ) config.zerozawa.ssh.machines
      )
    );
    "remote.SSH.useLocalServer" = false;
  };
}
