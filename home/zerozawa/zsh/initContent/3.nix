{
  lib,
  ...
}:

{
  programs.zsh = {
    initContent = lib.mkAfter ''
      hitokoto
    '';
  };
}
