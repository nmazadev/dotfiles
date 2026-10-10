#!/bin/bash
#   _ _ _ _____ __    __    _____ _____ _____ _____ _____ 
#  | | | |  _  |  |  |  |  |  _  |  _  |  _  |   __| __  |
#  | | | |     |  |__|  |__|   __|     |   __|   __|    -|
#  |_____|__|__|_____|_____|__|  |__|__|__|  |_____|__|__|
#
#  by Bina
#
# Usage: wallpaper.sh [init]
#   (none) set a random wallpaper
#   init   re-apply the saved wallpaper and theme (called at login)
# With the pywal theme the colors follow the wallpaper; with a fixed theme
# (see theme.sh) only the wallpaper changes.

current_wp="$HOME/wallpapers/current_wallpaper"
blurred_wp="$HOME/wallpapers/current_wallpaper_blurred.png"
blur="50x30"
theme=$(cat "$HOME/.cache/wal/theme" 2>/dev/null || echo cocoa)

images() {
    find "$HOME/wallpapers" -maxdepth 1 -type f \
        \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) \
        ! -name "current_wallpaper*"
}

# select the wallpaper
saved=$(cat "$current_wp" 2>/dev/null)
if [ "$1" = "init" ] && [ -f "$saved" ]; then
    wallpaper="$saved"
else
    wallpaper=$(images | shuf -n 1)
fi

if [ ! -f "$wallpaper" ]; then
    notify-send "No wallpapers" "Put images in ~/wallpapers"
    exit 1
fi

# colors: pywal derives them from the image, fixed themes reapply their palette
if [ "$theme" = "pywal" ]; then
    wal -n -q -i "$wallpaper"
    "$HOME/.config/hypr/scripts/gtk-theme.sh"
else
    "$HOME/.config/hypr/scripts/theme.sh" "$theme" --no-reload
fi

# launch waybar with the fresh colors
~/.config/waybar/launch.sh

# notifications pick up the new colors
makoctl reload 2>/dev/null

# update soft link to cava colors based on the theme colors
# (cava needs to manually be restarted)
ln -sf "$HOME/.cache/wal/cava-colors" "$HOME/.config/cava/config"

# switch to new wallpaper with awww
transition_type="grow"
#transition_type="wipe"
# transition_type="random"

awww img "$wallpaper" \
    --transition-type="$transition_type" \
    --transition-pos top-right

# create blurred wallpaper (for wlogout), cropped to fill the screen.
# The original image is never modified.
# Runs in the background so SUPER+W returns right away. Written to a temp file and
# moved into place: wlogout opened mid-write got a half PNG, which GTK paints red.
# At login it's skipped when the blurred file is already newer than the wallpaper.
if [ ! "$blur" == "0x0" ] && ! { [ "$1" = "init" ] && [ "$blurred_wp" -nt "$wallpaper" ]; }; then
    tmp="${blurred_wp%.png}.tmp.png"
    { magick "$wallpaper" -resize '1920x1080^' -gravity center -extent 1920x1080 \
        -blur "$blur" "$tmp" && mv -f "$tmp" "$blurred_wp"; } &
fi

# update current wallpaper file
echo "$wallpaper" > "$current_wp"
