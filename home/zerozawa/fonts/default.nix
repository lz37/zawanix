{ config, ... }:

{
  xdg.dataFile = {
    "fonts/mtextra.ttf" = {
      source = config.lib.file.mkOutOfStoreSymlink ./mtextra.ttf;
      force = true;
    };
    "fonts/Wingdings 2.ttf" = {
      source = config.lib.file.mkOutOfStoreSymlink ./Wingdings2.ttf;
      force = true;
    };
    "fonts/Wingdings 3.ttf" = {
      source = config.lib.file.mkOutOfStoreSymlink ./Wingdings3.ttf;
      force = true;
    };
  };
}
