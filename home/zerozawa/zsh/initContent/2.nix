{
  lib,
  ...
}:
let
  variable_pub = (import ../../../../options/variable-pub.nix);
in
{

  programs.zsh = {
    initContent = lib.mkOrder 1000 ''
      # p10k
      # To customize prompt, run `p10k configure` or edit ${variable_pub.path.p10k}.
      [[ ! -f ${variable_pub.path.p10k} ]] || source ${variable_pub.path.p10k}
    '';
  };
}
