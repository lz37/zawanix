{
  lib,
  ...
}:

{

  programs.zsh = {
    initContent = lib.mkBefore '''';
  };
}
