{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  hw = config.zerozawa.hardware;

  # 610.57.04: 最后一个 Wilds 不触发 Xid 109 的分支。
  # 用仍把 610 作为 new_feature 的旧 nixpkgs 表达式 + 当前 kernel 实例化，
  # 保证内核模块与 libs 同版本、且模块针对当前 CachyOS 内核编译。
  nvidia610 = let
    oldPkgs = import inputs.nixpkgs-nvidia610 {
      system = pkgs.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };
    };
    driver = (oldPkgs.linuxPackagesFor config.boot.kernelPackages.kernel).nvidiaPackages.new_feature;
  in
    driver.overrideAttrs (old: {
      # 内核 7.2 的 gpio_device_get_chip() 参数为非 const，610 的 __to_hwgpio()
      # 兼容 shim 仍是 const，clang -Werror 报 discards qualifiers。
      # new_feature 是 generic 直接调用结果，必须替换 passthru.open 才能影响内核模块。
      passthru =
        old.passthru
        // {
          open = old.passthru.open.override {
            patches = [./nvidia-open-gpio-const.patch];
          };
        };
    });

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

      package = nvidia610;

      prime = {
        offload = {
          enable = needsPrimeOffload;
          enableOffloadCmd = needsPrimeOffload;
        };

        # External GPU support: required for OCuLink eGPU PRIME setup.
        allowExternalGpu = hw.isOculink;

        # Auto-derived bus IDs from facter PCI topology.
        # These are mkDefault so per-host overrides can still win.
        nvidiaBusId = lib.mkDefault (
          if nvidiaPrimeBusId != null
          then nvidiaPrimeBusId
          else ""
        );

        intelBusId = lib.mkIf (needsPrimeOffload && intelPrimeBusId != null) (
          lib.mkDefault intelPrimeBusId
        );

        amdgpuBusId = lib.mkIf (needsPrimeOffload && intelDev == null && amdPrimeBusId != null) (
          lib.mkDefault amdPrimeBusId
        );
      };

      # Dynamic Boost balances CPU/GPU power. Only makes sense for internal
      # laptop dGPUs sharing power budget with the CPU, not for eGPUs.
      dynamicBoost.enable = isInternalHybridLaptop;
    };
  }
