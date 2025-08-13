{ ... }:

{
  services.flatpak = {
    enable = true;
    packages = [
      "cn.feishu.Feishu"
      "com.tencent.wemeet"
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    uninstallUnused = true;
  };
}
