{ pkgs, config, ... }:

{
  extensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
  ];
  settings = {
    "remote.SSH.remotePlatform" = config.zerozawa.vscode.remote.SSH.remotePlatform;
    "remote.SSH.useLocalServer" = false;
  };
}
