{
  pkgs,
  ...
}:

{
  users.users.zerozawa = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "podman"
    ];
    shell = pkgs.zsh;
  };
}
