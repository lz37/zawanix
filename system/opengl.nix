{
  pkgs,
  isNvidiaGPU,
  isIntelGPU,
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
      (
        (lib.optionals isNvidiaGPU [
          nvidia-vaapi-driver
          nv-codec-headers-12
          vaapiVdpau
          libvdpau-va-gl
        ])
        ++ (lib.optionals isIntelGPU [
          intel-media-driver
          intel-ocl
          intel-compute-runtime
          (pkgs.vpl-gpu-rt or pkgs.onevpl-intel-gpu)
        ])
      )
    );
    extraPackages32 = (
      with pkgs.pkgsi686Linux;
      (
        (lib.optionals isNvidiaGPU [
          libvdpau-va-gl
          vaapiVdpau
        ])
        ++ (lib.optionals isIntelGPU [
          intel-media-driver
        ])
      )
    );
  };
}
