{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ((fortune.override {
        withOffensive = true;
      }).overrideAttrs
      (old: {
        postFixup =
          old.postFixup
          + ''
            cp -r ${nur.repos.zerozawa.fortune-mod-zh}/share/fortune/* $out/share/games/fortunes/
          '';
      }))
    wakatime
    fd
    translate-shell
    tldr
    ventoy-full
  ];
}
