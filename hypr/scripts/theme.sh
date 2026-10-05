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
    ""|--no-reload) choice=$(printf '%s\n' "${themes[@]}" | wofi --dmenu --prompt "theme ($current)" --style "$HOME/.cache/wal/wofi.css" --height 260 --width 360) ;;
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

# tlock (2FA TUI) can't load custom themes: pick its closest built-in one. It keeps
# the choice in a tiny binary file: the theme name prefixed by its length.
case "$choice" in
    rose-pine-moon) tlock_theme="Rose Pine" ;;
    nord) tlock_theme="Nord" ;;
    gruvbox|cocoa) tlock_theme="Gruvbox" ;;
    *) tlock_theme="" ;;
esac
if [ -n "$tlock_theme" ]; then
    mkdir -p "$HOME/.config/tlock"
    printf "\\x$(printf %02x ${#tlock_theme})%s" "$tlock_theme" > "$HOME/.config/tlock/config_internal_ignore.bin"
fi
"$HOME/.config/hypr/scripts/gtk-theme.sh"

# --no-reload is for callers that restart waybar and mako themselves
[[ " $* " == *" --no-reload "* ]] && exit 0

"$HOME/.config/waybar/launch.sh"
makoctl reload 2>/dev/null
pkill -USR2 -x btop 2>/dev/null   # btop reloads its config and theme
hyprctl reload >/dev/null 2>&1
notify-send "Theme" "$choice"
