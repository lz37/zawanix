{
  pkgs,
  isNvidiaGPU,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
    virglrenderer
  ];

  # 修复 libvirtd 12.1.0 secret 加密密钥问题
  # 使用 systemd-creds encrypt 生成符合 LoadCredentialEncrypted 的加密格式
  system.activationScripts.fix-libvirtd-secret = lib.stringAfter ["var"] ''
    # 创建 secrets 目录
    mkdir -p /var/lib/libvirt/secrets

    # 检查密钥文件是否存在且是有效的 systemd-creds 加密格式
    KEY_FILE="/var/lib/libvirt/secrets/secrets-encryption-key"

    # 如果文件不存在，或者文件存在但无法被 systemd-creds 解密，则重新生成
    NEED_NEW_KEY=0
    if [ ! -f "$KEY_FILE" ]; then
      NEED_NEW_KEY=1
    else
      # 尝试解密，如果失败说明不是有效的加密格式
      if ! ${pkgs.systemd}/bin/systemd-creds decrypt "$KEY_FILE" /dev/null 2>/dev/null; then
        NEED_NEW_KEY=1
      fi
    fi

    if [ "$NEED_NEW_KEY" -eq 1 ]; then
      # 删除旧的密钥文件（如果存在）
      rm -f "$KEY_FILE"

      # 生成 32 字节随机二进制密钥并使用 systemd-creds 加密
      # 注意：使用 openssl rand 32 (不是 -base64) 生成原始二进制数据
      ${pkgs.openssl}/bin/openssl rand 32 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - "$KEY_FILE"
      chmod 600 "$KEY_FILE"
      chown root:root "$KEY_FILE"
      echo "Created new systemd-creds encrypted libvirt secret key (32 bytes binary)"
    fi
  '';

  virtualisation = with pkgs; {
    # kvm
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [virtiofsd];
        package = qemu;
        swtpm = {
          enable = true;
          package = swtpm;
        };
        verbatimConfig =
          if isNvidiaGPU
          then ''
            namespaces = []
            cgroup_device_acl = [
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm",
              "/dev/nvidiactl", "/dev/nvidia0", "/dev/nvidia-modeset", "/dev/dri/renderD128"
            ]
            seccomp_sandbox = 0
          ''
          else ''
            namespaces = []
          '';
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
