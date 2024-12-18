# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

let
  CN = "zh_CN.UTF-8";
in

{
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  # Select internationalisation properties.
  i18n.defaultLocale = CN;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = CN;
    LC_IDENTIFICATION = CN;
    LC_MEASUREMENT = CN;
    LC_MONETARY = CN;
    LC_NAME = CN;
    LC_NUMERIC = CN;
    LC_PAPER = CN;
    LC_TELEPHONE = CN;
    LC_TIME = CN;
  };
}
