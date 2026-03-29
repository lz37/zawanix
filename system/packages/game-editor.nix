{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    blender
    unityhub
    godot-mono
    furmark # GPU 压力测试
    unigine-heaven # GPU 基准
    phoronix-test-suite # 综合测试
    sysbench # CPU/内存测试
    geekbench # CPU 测试
  ];
}
