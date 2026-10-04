local vars = require("vars")
local home = os.getenv("HOME")
local mod = vars.mainMod

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + A", hl.dsp.exec_cmd(vars.menu))
hl.bind(mod .. " + D", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(home .. "/.config/waybar/launch.sh"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

hl.bind(mod .. " + W", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh"))

hl.bind(mod .. " + M", hl.dsp.exec_cmd("wlogout -b 2"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("makoctl mode -t do-not-disturb >/dev/null; pkill -RTMIN+8 waybar"), { description = "Toggle do not disturb" })
hl.bind(mod .. " + T", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/theme.sh"))
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/theme.sh next"))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

-- Screenshots: the Print key (Fn+F12 on laptops), opened in satty
hl.bind("Print", hl.dsp.exec_cmd(home .. "/.local/bin/screenshot area"), { description = "Screenshot of an area" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(home .. "/.local/bin/screenshot screen"), { description = "Screenshot of the focused monitor" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(home .. "/.local/bin/screenshot all"), { description = "Screenshot of all monitors" })
hl.bind("ALT + Print", hl.dsp.exec_cmd(home .. "/.local/bin/screenshot window"), { description = "Screenshot of the focused window" })
hl.bind(mod .. " + Print", hl.dsp.exec_cmd(home .. "/.local/bin/screenshot screen --delay 5"), { description = "Screenshot after 5 s" })

-- SYSTEM CONTROLS
-- Volume (PipeWire)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.0"), { description = "Increase volume", repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { description = "Decrease volume", repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "Toggle audio mute", locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "Toggle microphone mute", locked = true })

-- Player
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play or pause media", locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { description = "Play or pause media", locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Next track", locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous track", locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { description = "Stop playback", locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +2%"), { description = "Increase brightness", repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"), { description = "Decrease brightness", repeating = true, locked = true })

-- HYPRLAND
-- Session actions
hl.bind(mod .. " + Delete", hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind("CTRL + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland config" })

-- Window actions
hl.bind(mod .. " + k", hl.dsp.window.kill(), { description = "Kill window" })
hl.bind("ALT + Return", hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })

-- Focus
hl.bind("ALT + Tab", hl.dsp.focus({ direction = "down" }), { description = "Switch to next window" })

-- Workspace navigation
hl.bind(mod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }), { description = "Next workspace" })
hl.bind(mod .. " + CTRL + left", hl.dsp.focus({ workspace = "r-1" }), { description = "Previous workspace" })
hl.bind(mod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }), { description = "First empty workspace" })

-- Move windows
hl.bind(mod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ direction = "right" }), { description = "Move window right" })
hl.bind(mod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ direction = "left" }), { description = "Move window left" })
hl.bind(mod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ direction = "up" }), { description = "Move window up" })
hl.bind(mod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ direction = "down" }), { description = "Move window down" })
