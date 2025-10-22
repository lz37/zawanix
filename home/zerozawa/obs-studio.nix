{pkgs, ...}: {
  programs.obs-studio = {
    # a=pkgs.obs-studio;
    enable = true;
    package = pkgs.obs-studio;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      obs-backgroundremoval
      waveform
      obs-vaapi
      obs-tuna
      obs-advanced-masks
    ];
  };
}
