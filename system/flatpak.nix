{ ... }:

{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://mirror.sjtu.edu.cn/flathub";
      }
      {
        name = "flathub-origin";
        location = "https://dl.flathub.org/repo/";
      }
    ];
    packages = [
      # { appId = "com.visualstudio.code"; origin = "flathub"; }
      # { appId = "com.github.iwalton3.jellyfin-media-player"; origin = "flathub"; }
      {
        appId = "com.qq.QQ";
        origin = "flathub";
      }
      {
        appId = "org.telegram.desktop";
        origin = "flathub";
      }
      {
        appId = "com.tencent.WeChat";
        origin = "flathub";
      }
      # {
      #   appId = "com.tencent.wemeet";
      #   origin = "flathub";
      # }
      {
        appId = "cn.xfangfang.wiliwili";
        origin = "flathub";
      }
      {
        appId = "com.github.tchx84.Flatseal";
        origin = "flathub";
      }
      {
        appId = "io.github.giantpinkrobots.flatsweep";
        origin = "flathub";
      }
      # {
      #   appId = "io.github.Figma_Linux.figma_linux";
      #   origin = "flathub";
      # }
      # {
      #   appId = "com.microsoft.Edge";
      #   origin = "flathub";
      # }
      # { appId = "com.qq.QQmusic"; origin = "flathub"; }
      # { appId = "com.netease.CloudMusic"; origin = "flathub"; }
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
  };

}
