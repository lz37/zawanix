-- DMS entry point. Loads all DMS-generated modules.
-- Each is wrapped in pcall so first boot doesn't fail when files are missing.
pcall(require, "dms.colors")
pcall(require, "dms.layout")
pcall(require, "dms.cursor")
pcall(require, "dms.windowrules")
