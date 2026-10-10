#!/bin/bash
# Run once from autostart.lua: restore the wallpaper and pywal colors, then
# start waybar. Works on a fresh install, where ~/wallpapers may be empty.

# awww needs its daemon up before it accepts an image
for _ in $(seq 50); do
    awww query >/dev/null 2>&1 && break
    sleep 0.1
done

if find "$HOME/wallpapers" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) 2>/dev/null | grep -q .; then
    # sets the wallpaper, writes the pywal cache and launches waybar
    "$HOME/.config/hypr/scripts/wallpaper.sh" init
else
    notify-send "No wallpapers" "Put images in ~/wallpapers and press SUPER+W"
    # still generate the theme colors waybar needs
    theme=$(cat "$HOME/.cache/wal/theme" 2>/dev/null || echo cocoa)
    [ "$theme" = "pywal" ] && theme=cocoa
    "$HOME/.config/hypr/scripts/theme.sh" "$theme" --no-reload
    "$HOME/.config/waybar/launch.sh"
fi

# From now on monitor.added is a real hotplug: the event Hyprland sends for the
# screens it starts with is ignored by monitor-hotplug.sh until this marker exists
touch "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/startup-done"
