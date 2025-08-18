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
    package = pkgs.hyprland-git-nixpkgs-pkgs.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs.hyprland-git-nixpkgs-pkgs.pkgsi686Linux.mesa;
    extraPackages = lib.mkForce (
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
          intel-vaapi-driver
          intel-compute-runtime
          (pkgs.vpl-gpu-rt or pkgs.onevpl-intel-gpu)
        ])
      )
    );
    extraPackages32 = lib.mkForce (
      with pkgs.pkgsi686Linux;
      (
        (lib.optionals isNvidiaGPU [
          libvdpau-va-gl
          vaapiVdpau
        ])
        ++ (lib.optionals isIntelGPU [
          intel-media-driver
          intel-vaapi-driver
        ])
      )
    );
  };
}
