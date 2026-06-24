-- option.schema.lua — Type stub for LSP. Hand-written, git-committed.
---@class OptionHardwareDrm
---@field aqDrmDevices string Colon-separated DRM device paths

---@class OptionHardware
---@field isNvidiaGPU boolean
---@field isAmdGPU boolean
---@field isIntelGPU boolean
---@field isIntelCPU boolean
---@field isAMDCPU boolean
---@field isLaptop boolean
---@field isSSD boolean
---@field isFingerprint boolean
---@field isOculink boolean
---@field ram number
---@field amd64Microarchs string
---@field drm OptionHardwareDrm

---@class OptionPath
---@field home string Home directory path

---@class Option
---@field hardware OptionHardware
---@field path OptionPath

local M = {
    hardware = {
        isNvidiaGPU = false,
        isAmdGPU = true,
        isIntelGPU = false,
        isIntelCPU = false,
        isAMDCPU = true,
        isLaptop = false,
        isSSD = true,
        isFingerprint = false,
        isOculink = false,
        ram = 32,
        amd64Microarchs = "zen4",
        drm = {
            aqDrmDevices = "/dev/dri/card0",
        },
    },
    path = {
        home = "/home/zerozawa",
    },
}
return M
