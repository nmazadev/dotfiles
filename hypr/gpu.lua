-- GPU setup, detected from sysfs so the same config works on Intel-only and
-- hybrid Intel + NVIDIA laptops. Hybrid branch adapted from meowrch's gpu-env.lua.
--
--   Intel only : no overrides (Hyprland's auto-detection is right).
--   Hybrid     : the iGPU drives the compositor; the dGPU is only used per-app
--                via bin/prime-run.
--   Other      : no overrides (NVIDIA-only/AMD are not handled here).

local function exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

local function read(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

-- Returns the /dev/dri/cardN path of each GPU, keyed by vendor. Detected fresh
-- on every start, so card numbering changes between boots don't matter. The
-- by-path names can't be used: they contain ':' which is also the separator
-- of AQ_DRM_DEVICES, so Aquamarine splits them apart and finds no GPUs.
local function detect_gpus()
    local gpus = {}
    for n = 0, 7 do
        local dir = "/sys/class/drm/card" .. n .. "/device/"
        local vendor = read(dir .. "vendor")
        if vendor then
            vendor = vendor:match("0x(%x+)")
            local path = "/dev/dri/card" .. n
            if vendor == "8086" then gpus.intel = gpus.intel or path end
            if vendor == "10de" then gpus.nvidia = gpus.nvidia or path end
        end
    end
    return gpus
end

local gpus = detect_gpus()

if gpus.intel and gpus.nvidia then
    -- Intel first so Hyprland renders on it.
    hl.env("AQ_DRM_DEVICES", gpus.intel .. ":" .. gpus.nvidia)

    -- Avoids cursor hitches on NVIDIA setups.
    hl.config({
        cursor = {
            no_hardware_cursors = true,
        },
    })

    -- VA-API decode through NVIDIA; needs the libva-nvidia-driver package.
    if exists("/usr/lib/dri/nvidia_drv_video.so") or exists("/usr/lib64/dri/nvidia_drv_video.so") then
        hl.env("NVD_BACKEND", "direct")
    end

    -- Deliberately NOT set globally (would force every app onto the dGPU):
    -- __GLX_VENDOR_LIBRARY_NAME, GBM_BACKEND, LIBVA_DRIVER_NAME, VK_LAYER_NV_optimus
end
