{
  pkgs,
  isNvidiaGPU,
  lib,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    package = pkgs.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs.pkgsi686Linux.mesa;
    extraPackages = (
      with pkgs;
      (lib.optionals isNvidiaGPU [
        nvidia-vaapi-driver
        nv-codec-headers-12
        vaapiVdpau
        libvdpau-va-gl
      ])
    );
    extraPackages32 = (
      with pkgs.pkgsi686Linux;
      (lib.optionals isNvidiaGPU [
        libvdpau-va-gl
        vaapiVdpau
      ])
    );
  };
}
