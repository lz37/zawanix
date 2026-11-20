{ ... }: {
  # 三级交换路径：RAM → zswap 压缩池 → swapfile（见 system/fs.nix）。
  # zswap 是 swap 写入路径上的压缩缓存，不是设备：页先在 RAM 里压缩，池满/回收冷页时才写回 swapfile。
  # 与 zram 二选一（boot.zswap 模块的 assertion 禁止 zramSwap.enable 同时为真）。
  boot.zswap = {
    enable = true;
    compressor = "zstd";
    maxPoolPercent = 25; # 32 GiB RAM × 25% = 8 GiB 压缩池，按实测 3.1× 约等于 25 GiB 逻辑页
    shrinkerEnabled = true; # 内存压力下把池内冷页回写到 swapfile
  };
}
