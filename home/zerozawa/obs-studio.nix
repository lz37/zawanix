{pkgs, ...}: {
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-websocket
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-source-clone
      obs-move-transition
      obs-composite-blur
      # obs-backgroundremoval
      waveform
      obs-vaapi
      obs-tuna
      obs-advanced-masks
      obs-vnc
      obs-rgb-levels
      obs-media-controls
      obs-markdown
      obs-command-source
      obs-aitum-multistream
      input-overlay
      pixel-art
    ];
  };
}
