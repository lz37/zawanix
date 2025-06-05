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
      config.zerozawa.ssh.machines
      |> lib.map (
        {
          host,
          type,
          ...
        }:
        {
          name = host;
          value = type;
        }
      )
      |> builtins.listToAttrs
    );
    "remote.SSH.useLocalServer" = false;
  };
}
