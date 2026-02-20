# NixOS 内核配置规则

## 概述

本规则定义了 NixOS 内核配置的最佳实践，特别是针对 CachyOS 内核的条件化配置。

## 核心原则

### 1. 精细条件化

**不要**按机器类型整体配置，而是按属性精细拆分：

```nix
# ✅ 正确：每个属性独立条件化
hzTicks =
  if isLaptop && !isGameMachine
  then "300"
  else "1000";

# ❌ 错误：整台机器的配置混在一起
{ config, ... }: {
  boot.kernelPackages = ...;  # Desktop 配置
}
```

### 2. 利用已有的 specialArgs

flake.nix 已经传递了以下参数，应该充分利用：

- `isIntelCPU` / `isAmdCPU`
- `isIntelGPU` / `isNvidiaGPU` / `isAmdGPU`
- `isLaptop`
- `isGameMachine`
- `amd64Microarchs`
- `hostName`

### 3. 单文件配置

保持 `system/kernel.nix` 单文件结构，不要拆分成多个文件：

```nix
# ✅ 正确：单文件，属性级条件化
{
  boot.kernelParams = [通用参数]
    ++ lib.optionals isIntelCPU [Intel参数]
    ++ lib.optionals isNvidiaGPU [NVIDIA参数]
    ++ lib.optionals (isLaptop && isGameMachine) [游戏本参数];
}
```

## 配置模式

### 内核包配置

```nix
boot.kernelPackages = pkgs.linuxKernel.packagesFor (
  pkgs.cachyosKernels.linux-cachyos-latest.override {
    lto = "thin";
    processorOpt = "x86_64-v${lib.strings.substring 8 1 amd64Microarchs}";
    cpusched = "bore";
    rt = false;  # 禁用实时内核，解决延迟问题
    bbr3 = true;
    ccHarder = true;
    hzTicks =
      if isLaptop && !isGameMachine
      then "300"      # 普通笔记本省电
      else "1000";    # 台式机/游戏本性能优先
    hugepage = "always";
  }
);
```

### 内核参数条件化

```nix
boot.kernelParams = [通用参数]
  # CPU 相关
  ++ (lib.optionals isIntelCPU [
    "intel_iommu=on"
    "iommu=pt"
  ])
  
  # GPU 相关
  ++ (lib.optionals isNvidiaGPU [
    "nvidia_drm.modeset=1"
    "nvidia.NVreg_UsePageAttributeTable=1"
  ])
  
  # 机器类型相关
  ++ (lib.optionals (!isLaptop || isGameMachine) [
    "hugepagesz=1G"
    "hugepages=8"  # 性能机器大页
  ]);
```

### Sysctl 条件化

```nix
boot.kernel.sysctl = {
  # 通用配置
  "vm.max_map_count" = 2147483642;
  "fs.file-max" = 2097152;
}
// (  # 使用 // 合并
  if !isLaptop || isGameMachine
  then {
    # 性能机器调度优化
    "kernel.sched_latency_ns" = 4000000;
    "kernel.sched_min_granularity_ns" = 500000;
  }
  else {}
);
```

## 场景矩阵

| 场景 | 条件 | 配置 |
|------|------|------|
| 台式机 | `!isLaptop` | 1000Hz, 8 hugepages, 性能调度 |
| 普通笔记本 | `isLaptop && !isGameMachine` | 300Hz, 省电调度 |
| 游戏本 | `isLaptop && isGameMachine` | 1000Hz, 4 hugepages, 性能调度 |
| Intel CPU | `isIntelCPU` | intel_iommu, iTCO_wdt |
| NVIDIA GPU | `isNvidiaGPU` | nvidia_drm, NVreg 参数 |

## 禁止事项

1. **不要**创建 `system/kernel/common.nix`, `desktop.nix`, `laptop.nix` 等拆分文件
2. **不要**使用 `hostName` 作为主要条件（除非必要）
3. **不要**按机器类型整体复制粘贴配置
4. **不要**使用 `mySystem.machineType` 等自定义选项

## 推荐结构

```
system/
└── kernel.nix          # 单文件，属性级条件化
```

## 参考实现

见 `/etc/nixos/system/kernel.nix` - 这是正确的实现示例。
