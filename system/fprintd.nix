{
  config,
  lib,
  ...
}: let
  hw = config.zerozawa.hardware;
in {
  config = lib.mkIf hw.isFingerprint {
    # fprintd — fingerprint authentication daemon
    # Uses mainline libfprint (supports USB Elan 04f3:0c8c natively).
    # No TOD driver needed — libfprint-2-tod1-elan is for SPI sensors (04f3:0c4b) only.
    services.fprintd.enable = true;

    # PAM: enable fingerprint auth.
    # NOTE: SDDM's PAM service uses "substack login" for auth,
    # so login.fprintAuth MUST be true (the default) for SDDM to get fprintd.
    # sddm.fprintAuth here is a no-op (SDDM has useDefaultRules=false) but kept as docs.
    security.pam.services = {
      sddm.fprintAuth = true;
      sudo.fprintAuth = true;
    };
  };
}
