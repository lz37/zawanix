{
  ...
}:

{

  programs.zsh = {
    initContent = ''
      # p10k
      # To customize prompt, run `p10k configure` or edit ${(import ../../options/variable-pub.nix).path.p10k}.
      [[ ! -f ${(import ../../options/variable-pub.nix).path.p10k} ]] || source ${(import ../../options/variable-pub.nix).path.p10k}
    '';
  };
}
