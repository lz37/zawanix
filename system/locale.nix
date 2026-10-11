{...}: {
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  i18n = {
    # Select internationalisation properties.
    # 只导出 LANG：覆盖全部 LC_* 类别，桌面行为与逐项 pin 等价；
    # 逐项 pin LC_CTYPE 会压制 per-process 的 LANG=xx 覆盖，故不设 extraLocaleSettings。
    defaultLocale = "zh_CN.UTF-8";
    # 供 LANG=ja_JP.UTF-8 这类"只设 LANG"的启动方式使用（wine/galgame）。
    extraLocales = ["ja_JP.UTF-8/UTF-8"];
  };
}
