{ lib, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde6";
  };
}
