{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (
      (fortune.override {
        withOffensive = true;
      }).overrideAttrs
      (old: {
        postFixup =
          old.postFixup
          + (lib.concatStringsSep "\n" (
            lib.map
            (fortune-mod: ''
              cp -r ${fortune-mod}/share/fortune/* $out/share/games/fortunes/
            '')
            (
              with nur.repos.zerozawa; [
                fortune-mod-zh
                fortune-mod-hitokoto
              ]
            )
          ));
      })
    )
    wakatime-cli
    fd
    pulseaudio # pactl — deskbrid audio backend shells out to it
    translate-shell
    tldr
    ventoy-full
    lolcat
    bili-live-tool
    github-copilot-cli
  ];
}
