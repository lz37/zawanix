-- DMS color bridge. Loads DMS-generated theme colors.
-- Silently fails if DMS hasn't written its files yet (first boot).
pcall(require, "dms.colors")
