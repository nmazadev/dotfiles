#!/bin/bash
# Switch the color theme of the whole desktop.
# Usage: theme.sh [name|next] [--no-reload]
#   no argument: pick from a wofi menu
# Themes: pywal (colors follow the wallpaper) and the fixed palettes in
# ~/.config/wal/colorschemes/*.json (repo: wal/colorschemes). Everything reads
# pywal's cache, so applying a theme just means regenerating that cache.

schemes="$HOME/.config/wal/colorschemes"
state="$HOME/.cache/wal/theme"
current_wp="$HOME/wallpapers/current_wallpaper"

themes=(pywal)
for f in "$schemes"/*.json; do
    [ -f "$f" ] && themes+=("$(basename "$f" .json)")
done

current=$(cat "$state" 2>/dev/null || echo cocoa)

choice="$1"
case "$choice" in
    ""|--no-reload) choice=$(printf '%s\n' "${themes[@]}" | wofi --dmenu --prompt "theme ($current)" ) ;;
    next)
        choice=${themes[0]}
        for i in "${!themes[@]}"; do
            [ "${themes[$i]}" = "$current" ] && choice=${themes[$(( (i + 1) % ${#themes[@]} ))]}
        done
        ;;
esac
[ -z "$choice" ] && exit 0

if [ "$choice" = "pywal" ]; then
    wp=$(cat "$current_wp" 2>/dev/null)
    if [ ! -f "$wp" ]; then
        notify-send "Theme" "pywal needs a wallpaper in ~/wallpapers"
        exit 1
    fi
    wal -n -q -i "$wp"
elif [ -f "$schemes/$choice.json" ]; then
    wal -n -q --theme "$schemes/$choice.json"
else
    notify-send "Theme" "Unknown theme: $choice"
    exit 1
fi

echo "$choice" > "$state"

# --no-reload is for callers that restart waybar and mako themselves
[[ " $* " == *" --no-reload "* ]] && exit 0

"$HOME/.config/waybar/launch.sh"
makoctl reload 2>/dev/null
hyprctl reload >/dev/null 2>&1
notify-send "Theme" "$choice"
