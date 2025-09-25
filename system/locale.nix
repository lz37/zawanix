{...}: {
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  i18n = rec {
    # Select internationalisation properties.
    defaultLocale = "zh_CN.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
      LC_ALL = defaultLocale;
      LANGUAGE = defaultLocale;
    };
  };
}
