{
  config,
  lib,
  ...
}:

{
  programs.zsh = {
    initContent = lib.After ''
      hitokoto
    '';
  };
}
