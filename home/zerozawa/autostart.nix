{pkgs, ...}: {
  xdg.autostart = {
    enable = true;
    readOnly = true;
    entries = with pkgs; [
      "${telegram-desktop_git}/share/applications/org.telegram.desktop.desktop"
      "${remmina}/share/applications/org.remmina.Remmina.desktop"
      "${jellyfin-mpv-shim}/share/applications/jellyfin-mpv-shim.desktop"
      "${svp}/share/applications/svp-manager4.desktop"
    ];
  };
}
