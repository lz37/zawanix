{
  pkgs,
  config,
  lib,
  ...
}:

{
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
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
