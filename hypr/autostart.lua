local hotplug = (os.getenv("HOME") or "") .. "/.config/hypr/scripts/monitor-hotplug.sh"

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
end)

-- New or removed monitors: wallpaper + waybar refresh (layout is handled by monitors.lua)
local function on_monitor(event)
    return function(mon)
        local name = type(mon) == "table" and mon.name or (type(mon) == "string" and mon or "")
        hl.exec_cmd(hotplug .. " " .. event .. " " .. name)
    end
end

hl.on("monitor.added", on_monitor("added"))
hl.on("monitor.removed", on_monitor("removed"))
