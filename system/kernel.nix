{
  pkgs,
  config,
  isIntelCPU,
  isIntelGPU,
  isNvidiaGPU,
  isLaptop,
  isGameMachine,
  amd64Microarchs,
  lib,
  ram,
  ...
}: {
  stylix.targets.console.enable = true;
  boot = {
    kernelPackages = pkgs.linuxKernel.packagesFor (pkgs.cachyosKernels.linux-cachyos-latest.override {
      lto = "thin";
      processorOpt = "x86_64-v${lib.strings.substring 8 1 amd64Microarchs}";
      rt = false;
      cpusched = "bore";
      bbr3 = true;
      ccHarder = true;
      hzTicks =
        if isLaptop && !isGameMachine
        then "300"
        else "1000";
      hugepage = "always";
    });
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback
    ];
    supportedFilesystems = [
      "btrfs"
      "ext4"
      "fat32"
      "ntfs"
    ];
    initrd = {
      enable = true;
      verbose = false;
      systemd.enable = true;
      availableKernelModules =
        [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "uas"
          "sd_mod"
          "ata_piix"
          "uhci_hcd"
          "sr_mod"
        ]
        ++ (lib.optionals isIntelGPU ["i915"]);
      kernelModules = [];
    };
    kernelParams =
      [
        "systemd.mask=systemd-vconsole-setup.service"
        "systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
        "nowatchdog"
        "modprobe.blacklist=sp5100_tco" # watchdog for AMD
        "modprobe.blacklist=iTCO_wdt" # watchdog for Intel
      ]
      ++ (lib.optionals isIntelCPU [
        "intel_iommu=on"
        "iommu=pt"
      ])
      ++ (lib.optionals isNvidiaGPU [
        "nvidia_drm.modeset=1"
        "nvidia.NVreg_UsePageAttributeTable=1"
        "nvidia.NVreg_EnablePCIeGen3=1"
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      ])
      ++ (lib.optionals (isGameMachine && ram >= 32 * 1024) [
        "hugepages=4"
        "hugepagesz=1G"
        "transparent_hugepage=always"
      ])
      ++ (lib.optionals (isGameMachine && ram < 32 * 1024 && ram >= 16 * 1024) [
        "hugepages=2"
        "hugepagesz=1G"
        "transparent_hugepage=always"
      ])
      ++ (lib.optionals (!isGameMachine || ram < 16 * 1024) ["transparent_hugepage=madvise"]);
    consoleLogLevel = 3;
    # Needed For Some Steam Games
    kernel.sysctl =
      {
        # Steam games requirement
        "vm.max_map_count" = 2147483642;
        "fs.file-max" = 1024 * 1024 * 2;

        # CachyOS performance tuning
        "kernel.sched_autogroup_enabled" = 1;
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        "net.core.netdev_max_backlog" = 16384;
        "net.core.somaxconn" = 8192;
        "net.core.rmem_default" = 1048576;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_default" = 1048576;
        "net.core.wmem_max" = 16777216;
        "net.core.optmem_max" = 65536;
        "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.ipv4.udp_rmem_min" = 8192;
        "net.ipv4.udp_wmem_min" = 8192;
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_max_syn_backlog" = 8192;
        "net.ipv4.tcp_max_tw_buckets" = 2000000;
        "net.ipv4.tcp_tw_reuse" = 1;
        "net.ipv4.tcp_fin_timeout" = 10;
        "net.ipv4.tcp_slow_start_after_idle" = 0;
        "net.ipv4.tcp_mtu_probing" = 1;

        # VM tuning
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.vfs_cache_pressure" = 50;
        "vm.swappiness" = 10;
      }
      // (
        if !isLaptop || isGameMachine
        then {
          "kernel.sched_latency_ns" = 4000000;
          "kernel.sched_min_granularity_ns" = 500000;
          "kernel.sched_wakeup_granularity_ns" = 500000;
        }
        else {}
      );
    plymouth = {
      enable = true;
      themePackages = [pkgs.catppuccin-plymouth];
      theme = "catppuccin-macchiato";
      font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFontMono-Regular.ttf";
    };
  };
  # Ananicy-cpp for process scheduling optimization
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
}
