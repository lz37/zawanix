{
  pkgs,
  config,
  lib,
  ...
}: let
  hw = config.zerozawa.hardware;
in {
  environment = {
    systemPackages = with pkgs; [
      clinfo
      gpu-viewer
    ];
    # OpenCL 环境变量
    variables = {
      OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
    };
  };

  hardware.graphics = {
    enable = true;
    package = pkgs.mesa;
    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs.pkgsi686Linux.mesa;
    extraPackages = (
      with pkgs; (
        # OpenCL ICD 加载器 (NVIDIA/Intel 使用，AMD 使用 ROCm 自带)
        (lib.optionals (!hw.isAmdGPU) [ocl-icd])
        ++ (lib.optionals hw.isNvidiaGPU [
          nvidia-vaapi-driver
          nv-codec-headers-12
          libva-vdpau-driver
          libvdpau-va-gl
        ])
        ++ (lib.optionals hw.isIntelGPU [
          intel-media-driver
          intel-ocl
          intel-compute-runtime
          (pkgs.vpl-gpu-rt or pkgs.onevpl-intel-gpu)
        ])
        ++ (lib.optionals hw.isAmdGPU (
          with rocmPackages; [
            # AMD OpenCL 支持 (ROCm 自带 OpenCL 运行时，不需要 ocl-icd)
            clr.icd
            clr
            rocm-runtime
          ]
        ))
      )
    );
    extraPackages32 = (
      with pkgs.pkgsi686Linux; (
        # 32-bit OpenCL ICD 加载器 (NVIDIA/Intel 使用，AMD 无 32-bit ROCm)
        (lib.optionals (!hw.isAmdGPU) [ocl-icd])
        ++ (lib.optionals hw.isNvidiaGPU [
          libvdpau-va-gl
          libva-vdpau-driver
        ])
        ++ (lib.optionals hw.isIntelGPU [
          intel-media-driver
        ])
      )
    );
  };
}
