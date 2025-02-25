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
    ])
    ++ (with pkgs; [
      plasmusic-toolbar
      (kdePackages.applet-window-buttons6.overrideAttrs (old: {
        version = "0.13.0-master";
        src = fetchFromGitHub {
          owner = "moodyhunter";
          repo = "applet-window-buttons6";
          rev = "master";
          hash = "sha256-HnlgBQKT99vVkl6DWqMkN8Vz+QzzZBGj5tqOJ22VkJ8=";
        };
      }))
    ]);
}
