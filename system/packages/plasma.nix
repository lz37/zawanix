{
  pkgs,
  pkgs-stable,
  ...
}:

{
  environment.systemPackages =
    (with pkgs.kdePackages; [
      yakuake
      kdecoration
      isoimagewriter
      # applet-window-buttons6
      kate
      qtwebsockets
      wallpaper-engine-plugin
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
      (kdePackages.applet-window-buttons6.overrideAttrs (old: rec {
        version = "0.14.0";
        src = fetchFromGitHub {
          owner = "moodyhunter";
          repo = "applet-window-buttons6";
          rev = "v${version}";
          hash = "sha256-HnlgBQKT99vVkl6DWqMkN8Vz+QzzZBGj5tqOJ22VkJ8=";
        };
      }))
    ]);
}
