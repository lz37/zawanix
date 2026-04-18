{
  lib,
  pkgs,
  ...
}: {
  # Place Files Inside Home Directory
  home.file = let
    inherit (pkgs.nur.repos.zerozawa.lib) fetchPixiv;
    face = fetchPixiv {
      id = 136104121;
      p = 0;
      hash = "sha256-JVz4l9hY5z6rLCXObwjH0UP04HI3qSxLLoTn1kwnfKE=";
      saveToshare = false;
    };
  in {
    "Pictures/Wallpapers" = {
      source = "${pkgs.buildEnv {
        name = "pixiv-wallpapers";
        paths = map fetchPixiv (lib.importTOML ./wallpapers.toml).pixiv;
      }}/share/pixiv";
      recursive = true;
    };
    ".face.icon".source = face;
    ".config/face.jpg".source = face;
  };
}
