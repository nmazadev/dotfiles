#!/bin/bash
# Called from autostart.lua on monitor.added / monitor.removed.
# Usage: monitor-hotplug.sh <added|removed> [monitor-name]

event="$1"
name="$2"

# Waybar follows the monitor layout, so relaunch it on any change
relaunch_waybar() {
    "$HOME/.config/waybar/launch.sh" >/dev/null 2>&1 &
}

if [ "$event" = "removed" ]; then
    relaunch_waybar
    exit 0
fi

# Never mirror: extend the desktop to the right instead
if [ -n "$name" ]; then
    mirror=$(hyprctl monitors -j | jq -r --arg n "$name" '.[] | select(.name == $n) | .mirrorOf')
    if [ -n "$mirror" ] && [ "$mirror" != "none" ]; then
        # the Lua config rejects "hyprctl keyword", so set the rule through eval
        hyprctl eval "hl.monitor({ output = \"$name\", mode = \"highrr\", position = \"auto-right\", scale = 1 })"
    fi
fi

# awww only draws on outputs it was told about: apply the current wallpaper
wp=$(cat "$HOME/wallpapers/current_wallpaper" 2>/dev/null)
if [ -f "$wp" ]; then
    if [ -n "$name" ]; then
        awww img "$wp" --outputs "$name" --transition-type none
    else
        awww img "$wp" --transition-type none
    fi
fi

relaunch_waybar
notify-send "Monitor connected" "${name:-new output}"
