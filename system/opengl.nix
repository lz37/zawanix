{
  pkgs,
  isNvidiaGPU,
  isIntelGPU,
  lib,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      clinfo
      ocl-icd
      gpu-viewer
    ];
    # OpenCL 环境变量
    variables = {
      OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
    };
  };

  hardware.graphics = {
    enable = true;
    package = pkgs.unstable-hyprland.pkgs.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs.unstable-hyprland.pkgs.pkgsi686Linux.mesa;
    extraPackages = (
      with pkgs; (
        (lib.optionals isNvidiaGPU [
          nvidia-vaapi-driver
          nv-codec-headers-12
          libva-vdpau-driver
          libvdpau-va-gl
        ])
        ++ (lib.optionals isIntelGPU [
          intel-media-driver
          intel-ocl
          intel-compute-runtime
          (pkgs.vpl-gpu-rt or pkgs.onevpl-intel-gpu)
          # OpenCL 支持相关包
          ocl-icd
        ])
      )
    );
    extraPackages32 = (
      with pkgs.pkgsi686Linux; (
        (lib.optionals isNvidiaGPU [
          libvdpau-va-gl
          libva-vdpau-driver
        ])
        ++ (lib.optionals isIntelGPU [
          intel-media-driver
        ])
      )
    );
  };
}
