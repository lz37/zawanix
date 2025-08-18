{
  pkgs,
  isIntelCPU,
  isIntelGPU,
  isVM,
  lib,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = [ "ntfs" ];
    initrd = {
      enable = true;
      verbose = false;
      systemd.enable = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "uas"
        "sd_mod"

        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sr_mod"
      ]
      ++ (lib.optionals isIntelGPU [ "i915" ]);
      kernelModules = [ ];
    };
    kernelModules = lib.optionals (!isVM) (lib.optionals isIntelCPU [ "kvm-intel" ]);
    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco" # watchdog for AMD
      "modprobe.blacklist=iTCO_wdt" # watchdog for Intel
    ]
    ++ (lib.optionals isIntelCPU [
      "intel_iommu=on"
      "iommu=pt"
    ]);
    consoleLogLevel = 3;
    # Needed For Some Steam Games
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    plymouth = {
      enable = true;
      themePackages = [ pkgs.catppuccin-plymouth ];
      theme = "catppuccin-macchiato";
      font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFontMono-Regular.ttf";
    };
  };
}
