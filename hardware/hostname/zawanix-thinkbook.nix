{
  inputs,
  lib,
  rootPath,
  ...
}:
let
  oculinkFacter = rootPath + "/hardware/facter/zawanix-thinkbook.oculink.json";
in
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c681d414-0087-40c2-8c1b-9e5c71eac1c2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6B80-4476";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  # OCuLink eGPU specialization: Intel iGPU + NVIDIA dGPU via OCuLink
  # Select "oculink" from systemd-boot menu when eGPU is connected.
  specialisation.oculink.configuration = {
    zerozawa.hardware.isOculink = lib.mkForce true;
    zerozawa.away-from-home = lib.mkForce false;
    # Switch to the oculink facter report which includes both GPUs.
    hardware.facter.reportPath = lib.mkForce oculinkFacter;

    # 仅 OCuLink 模式下 dock 在位时触发：GPE 0x6F 以 ~4.6k/s 刷 SCI（irq/9-acpi
    # 烧 74% 单核，全落 CPU0）。DSDT: `_L6F -> AL6F()` 的 AL6F 在全部 57 张表里
    # 都不存在，`SL6F()` 是空块 `If ((PGRT == One)){}` —— 固件 handler 不清源，
    # 而该 GPE 是 level-triggered，dock 拉高线后永久重触发。
    # 热插拔/AER 走 MSI（IRQ 129 仅 104 次、TOTAL_ERR_COR=1），mask 不丢通知；
    # 固件 SWCN20WW 已是公开最新，无修复可等。
    boot.kernelParams = [ "acpi_mask_gpe=0x6F" ];
  };
}
