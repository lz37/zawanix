{
  pkgs,
  config,
  lib,
  ...
}: {
  extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
  ];
  settings = {
    "remote.SSH.remotePlatform" =
      {
        "*" = "linux";
      }
      // (
        config.zerozawa.ssh.machines
        |> lib.filter (m: m.type == "macOS" || m.type == "windows")
        |> lib.map (m: {
          name =
            if m.hostname != null
            then m.hostname
            else m.host;
          value = m.type;
        })
        |> builtins.listToAttrs
      );
    "remote.SSH.useLocalServer" = false;
  };
}
