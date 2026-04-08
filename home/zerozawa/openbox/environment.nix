{...}: {
  xdg.configFile."openbox/environment" = {
    text = ''
      export XMODIFIERS=@im=fcitx
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export SDL_IM_MODULE=fcitx
    '';
  };
}
