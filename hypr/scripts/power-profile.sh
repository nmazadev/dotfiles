#!/bin/bash
# Power profile picker (power-profiles-daemon), opened from the waybar battery icon.
# Usage: power-profile.sh [profile|next]
#   no argument: wofi menu, the current profile marked with •

current=$(powerprofilesctl get)
mapfile -t profiles < <(powerprofilesctl list | sed -n 's/^[* ] *\([a-z-]*\):$/\1/p')

label() {
    case $1 in
        performance) echo "󰓅  performance" ;;
        balanced) echo "󰾅  balanced" ;;
        power-saver) echo "󰾆  power-saver" ;;
        *) echo "$1" ;;
    esac
}

choice=$1
if [ -z "$choice" ]; then
    menu=""
    for p in "${profiles[@]}"; do
        line=$(label "$p")
        [ "$p" = "$current" ] && line="$line  •"
        menu+="$line"$'\n'
    done
    picked=$(printf '%s' "$menu" | wofi --dmenu --prompt "power ($current)" \
        --style "$HOME/.cache/wal/wofi.css" --width 300 --height 200)
    [ -z "$picked" ] && exit 0
    choice=$(sed -E 's/^[^ ]+ +([a-z-]+).*/\1/' <<<"$picked")
elif [ "$choice" = next ]; then
    for i in "${!profiles[@]}"; do
        [ "${profiles[$i]}" = "$current" ] && choice=${profiles[$(( (i + 1) % ${#profiles[@]} ))]}
    done
fi

powerprofilesctl set "$choice" && notify-send -t 2000 "Power profile" "$(label "$choice")"
