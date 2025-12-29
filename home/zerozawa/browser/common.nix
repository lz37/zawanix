{
  commandLineArgs = [
    # wayland
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
    "--ozone-platform=wayland"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
    "--force-device-scale-factor"
    "--disable-features=WaylandWpColorManagerV1"
  ];
}
