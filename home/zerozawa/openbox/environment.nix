{...}: {
  xdg.configFile."openbox/environment" = {
    text = ''
      export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP:-Openbox}"
      export DESKTOP_SESSION="''${DESKTOP_SESSION:-openbox}"
      export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-x11}"
      export XMODIFIERS=@im=fcitx
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export SDL_IM_MODULE=fcitx
    '';
  };
}
