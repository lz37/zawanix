{
  lib,
  config,
  ...
}: let
  hw = config.zerozawa.hardware;

  # Does this host have a non-NVIDIA GPU (Intel or AMD integrated/discrete)?
  hasNonNvidiaGpu = hw.isIntelGPU || hw.isAmdGPU;

  # Internal hybrid laptop: has iGPU + dGPU, is laptop, NOT OCuLink eGPU.
  # Power management and dynamic boost make sense for internal laptop dGPUs,
  # but not for externally-powered OCuLink eGPUs.
  isInternalHybridLaptop = hasNonNvidiaGpu && hw.isLaptop && !hw.isOculink;

  # Needs PRIME render offload: NVIDIA renders, non-NVIDIA GPU displays.
  # Required for OCuLink eGPU (display goes through Intel iGPU) and for
  # internal hybrid laptops. NOT for desktop with NVIDIA as primary display.
  needsPrimeOffload = hw.isNvidiaGPU && hasNonNvidiaGpu && (isInternalHybridLaptop || hw.isOculink);

  # ── Auto-derive PRIME bus IDs from facter PCI data ──
  devices = hw.drm.devices or [];

  nvidiaDev = lib.findFirst (d: d.vendor == "nvidia") null devices;
  intelDev = lib.findFirst (d: d.vendor == "intel") null devices;
  amdDev = lib.findFirst (d: d.vendor == "amd") null devices;

  nvidiaPrimeBusId =
    if nvidiaDev != null
    then nvidiaDev.primeBusId or null
    else null;
  intelPrimeBusId =
    if intelDev != null
    then intelDev.primeBusId or null
    else null;
  amdPrimeBusId =
    if amdDev != null
    then amdDev.primeBusId or null
    else null;
in
  lib.mkIf hw.isNvidiaGPU {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # Modesetting is required for all NVIDIA hosts (Wayland compat).
      modesetting.enable = true;

      powerManagement = {
        # Power management: only for internal hybrid laptop dGPUs.
        # OCuLink eGPUs are externally powered; PM risks PCIe link instability.
        enable = isInternalHybridLaptop;
        # Fine-grained PM causes EGL context loss on OCuLink and others.
        finegrained = false;
      };

      # Use the open source NVIDIA kernel module.
      # RTX 5060 Ti (Blackwell) and RTX 40-series require open module.
      open = true;

      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.new_feature;

      prime = {
        offload = {
          enable = needsPrimeOffload;
          enableOffloadCmd = needsPrimeOffload;
        };

        # External GPU support: required for OCuLink eGPU PRIME setup.
        allowExternalGpu = hw.isOculink;

        # Auto-derived bus IDs from facter PCI topology.
        # These are mkDefault so per-host overrides can still win.
        nvidiaBusId =
          lib.mkDefault
          (
            if nvidiaPrimeBusId != null
            then nvidiaPrimeBusId
            else ""
          );

        intelBusId =
          lib.mkIf
          (needsPrimeOffload && intelPrimeBusId != null)
          (lib.mkDefault intelPrimeBusId);

        amdgpuBusId =
          lib.mkIf
          (needsPrimeOffload && intelDev == null && amdPrimeBusId != null)
          (lib.mkDefault amdPrimeBusId);
      };

      # Dynamic Boost balances CPU/GPU power. Only makes sense for internal
      # laptop dGPUs sharing power budget with the CPU, not for eGPUs.
      dynamicBoost.enable = isInternalHybridLaptop;
    };
  }
