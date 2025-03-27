{
  version = rec {
    nixos = "25.05";
    hm = nixos;
  };
  path = rec {
    cfgRoot = "/etc/nixos";
    p10k = "${cfgRoot}/profile/.p10k.zsh";
    home = "/home/zerozawa";
    code = "${home}/code";
    public = "${home}/Public";
  };
}
