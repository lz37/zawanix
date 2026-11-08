-- 所有第三方插件已禁用：nixpkgs 里没有与当前 Hyprland 版本匹配的构建。
--   dynamic-cursors: 打包版本与 Hyprland >= 0.56 的 ABI 不兼容。
--   hyprfocus: 只有 0.57.0 构建，而 Hyprland 是 0.57.1，配置键无法注册。
-- 恢复方式：把 .so 放回 ~/.config/hypr/plugins/，取消对应 load 与 hl.config 插件块。

-- hl.plugin.load(os.getenv("HOME") .. "/.config/hypr/plugins/hypr-dynamic-cursors.so")
-- hl.plugin.load(os.getenv("HOME") .. "/.config/hypr/plugins/hyprfocus.so")
