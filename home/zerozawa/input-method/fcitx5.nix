{
  pkgs,
  lib,
  ...
}: {
  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = (pkgs.formats.yaml {}).generate "default.custom.yaml" {
    patch = {
      __include = "rime_ice_suggestion:/";
    };
  };
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = with pkgs; {
      addons = [
        (fcitx5-rime.override
          {
            librime =
              (librime.override {
                plugins = [librime-lua librime-octagram];
              }).overrideAttrs (old: {
                buildInputs = (old.buildInputs or []) ++ [luajit];
              });
            rimeDataPkgs =
              [rime-data]
              ++ (with pkgs.nur.repos; (with xddxdd; [
                rime-ice # 这里postinstall添加词库
                rime-moegirl
                rime-zhwiki
                rime-dict
              ]));
          })
        fcitx5-rime
        fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-lua
      ];
      waylandFrontend = true;
      fcitx5-with-addons = kdePackages.fcitx5-with-addons;
      ignoreUserConfig = false;
      settings = let
        No = "No";
        True = "True";
        False = "False";
      in {
        inputMethod = let
          default = "默认";
        in {
          GroupOrder."0" = default;
          "Groups/0" = {
            # Group Name
            Name = default;
            # Layout
            "Default Layout" = "us";
            # Default Input Method
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "rime";
          "Groups/0/Items/1".Name = "keyboard-us";
          "Groups/0/Items/2".Name = "mozc";
        };
        globalOptions = {
          Hotkey = {
            # 反复按切换键时进行轮换
            EnumerateWithTriggerKeys = True;
            # 临时在当前和第一个输入法之间切换
            # AltTriggerKeys = "";
            # 轮换输入法时跳过第一个输入法
            EnumerateSkipFirst = False;
            # 触发修饰键快捷键的时限 (毫秒)
            ModifierOnlyKeyTimeout = 250;
          };
          "Hotkey/TriggerKeys"."0" = "Super+space";
          "Hotkey/EnumerateForwardKeys"."0" = "Control+Shift+Shift_L";
          "Hotkey/EnumerateBackwardKeys"."0" = "Control+Shift+Shift_R";
          "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
          "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
          "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
          "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
          "Hotkey/PrevPage"."0" = "Up";
          "Hotkey/NextPage"."0" = "Down";
          "Hotkey/PrevCandidate"."0" = "Shift+Tab";
          "Hotkey/NextCandidate"."0" = "Tab";
          "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
          Behavior = {
            # 默认状态为激活
            ActiveByDefault = False;
            # 重新聚焦时重置状态
            resetStateWhenFocusIn = No;
            # 共享输入状态
            ShareInputState = No;
            # 在程序中显示预编辑文本
            PreeditEnabledByDefault = True;
            # 切换输入法时显示输入法信息
            ShowInputMethodInformation = True;
            # 在焦点更改时显示输入法信息
            showInputMethodInformationWhenFocusIn = False;
            # 显示紧凑的输入法信息
            CompactInputMethodInformation = True;
            # 显示第一个输入法的信息
            ShowFirstInputMethodInformation = True;
            # 默认页大小
            DefaultPageSize = 5;
            # 覆盖 Xkb 选项
            OverrideXkbOption = False;
            # 自定义 Xkb 选项
            # CustomXkbOption = "";
            # Force Enabled Addons
            # EnabledAddons = "";
            # Force Disabled Addons
            # DisabledAddons = "";
            # Preload input method to be used by default
            PreloadInputMethod = True;
            # 允许在密码框中使用输入法
            AllowInputMethodForPassword = False;
            # 输入密码时显示预编辑文本
            ShowPreeditForPassword = False;
            # 保存用户数据的时间间隔（以分钟为单位）
            AutoSavePeriod = 30;
          };
        };
        addons = {
          notifications.sections.HiddenNotifications."0" = "wayland-diagnose-kde";
          chttrans = let
            default = "default";
          in {
            sections.Hotkey."0" = "Control+Shift+F";
            globalSection = {
              # 转换引擎
              Engine = "OpenCC";
              # 启用的输入法
              # EnabledIM = "";
              # 简转繁的 OpenCC 配置
              OpenCCS2TProfile = default;
              # 繁转简的 OpenCC 配置
              OpenCCT2SProfile = default;
            };
          };
          classicui.globalSection = {
            # 垂直候选列表
            "Vertical Candidate List" = True;
            # 使用鼠标滚轮翻页
            WheelForPaging = True;
            # 字体
            Font = lib.mkForce "霞鹜文楷 屏幕阅读版 10";
            # 菜单字体
            MenuFont = lib.mkForce "霞鹜文楷 屏幕阅读版 10";
            # 托盘字体
            TrayFont = lib.mkForce "霞鹜文楷 屏幕阅读版 10";
            # 托盘标签轮廓颜色
            TrayOutlineColor = "#000000";
            # 托盘标签文本颜色
            TrayTextColor = "#ffffff";
            # 优先使用文字图标
            PreferTextIcon = True;
            # 在图标中显示布局名称
            ShowLayoutNameInIcon = True;
            # 使用输入法的语言来显示文字
            UseInputMethodLanguageToDisplayText = True;
            # 主题
            # Theme = "stylix";
            # 深色主题
            # DarkTheme = "stylix";
            # 跟随系统浅色/深色设置
            UseDarkTheme = lib.mkForce False;
            # 当被主题和桌面支持时使用系统的重点色
            UseAccentColor = lib.mkForce False;
            # 在 X11 上针对不同屏幕使用单独的 DPI
            PerScreenDPI = False;
            # 固定 Wayland 的字体 DPI
            ForceWaylandDPI = 0;
            # 在 Wayland 下启用分数缩放
            EnableFractionalScale = True;
          };
        };
      };
    };
  };
}
