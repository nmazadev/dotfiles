local home = os.getenv("HOME") or ""
local hotplug = home .. "/.config/hypr/scripts/monitor-hotplug.sh"

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd(home .. "/.config/hypr/scripts/startup.sh")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    -- keeps hypridle from dimming/locking while music, video or a call is playing
    hl.exec_cmd(home .. "/.config/hypr/scripts/media-inhibit.sh")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
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
