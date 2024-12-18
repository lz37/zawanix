{
  ...
}:

{
  chaotic = {
    nyx = {
      cache.enable = true; # Whether to add Chaotic-Nyx's binary cache to settings.
      overlay = {
        enable = true; # Whether to add Chaotic-Nyx's overlay to system's pkgs.
        flakeNixpkgs.config = {
          allowUnfree = true;
        };
      };
    };
  };
}
