#!/bin/bash
# Build the GTK3/GTK4 stylesheets, the wofi stylesheet and the qt6ct palette from the current theme colors.
# GTK does not follow @import through our symlinks, so the colors and the repo's
# extra styling are concatenated into real files. Running apps need a restart.

repo=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)
colors="$HOME/.cache/wal/colors-gtk.css"
[ -f "$colors" ] || exit 0

for v in 3.0 4.0; do
    mkdir -p "$HOME/.config/gtk-$v"
    cat "$colors" "$repo/gtk-$v/extra.css" > "$HOME/.config/gtk-$v/gtk.css"
done

# wofi also fails to follow @import through the symlinked config folder, so the
# theme colors are prepended to its style. vars.lua points wofi at this file.
cat "$HOME/.cache/wal/colors-waybar.css" "$repo/wofi/style.css" > "$HOME/.cache/wal/wofi.css"

# Qt apps (the screen share picker, ...): a qt6ct palette from the same colors.
# Written as real files because qt6ct stores absolute paths.
mix() { # mix <#a> <#b> <percent of b>
    local a=${1#\#} b=${2#\#} p=$3 i out="#"
    for i in 0 2 4; do
        out+=$(printf '%02x' $(( (0x${a:i:2} * (100 - p) + 0x${b:i:2} * p) / 100 )))
    done
    echo "$out"
}
json="$HOME/.cache/wal/colors.json"
if [ -f "$json" ] && command -v jq >/dev/null; then
    bg=$(jq -r .special.background "$json") fg=$(jq -r .special.foreground "$json")
    accent=$(jq -r .special.cursor "$json") muted=$(jq -r .colors.color8 "$json")
    link2=$(jq -r .colors.color5 "$json")
    window=$(mix "$bg" "$fg" 5) surface=$(mix "$bg" "$fg" 10) light=$(mix "$bg" "$fg" 18)
    mid=$(mix "$bg" "$fg" 25) dark=$(mix "$bg" "#000000" 30)
    # WindowText Button Light Midlight Dark Mid Text BrightText ButtonText Base Window Shadow
    # Highlight HighlightedText Link LinkVisited AlternateBase NoRole ToolTipBase ToolTipText
    # PlaceholderText Accent
    row() { echo "$1, $surface, $light, $surface, $dark, $mid, $1, $fg, $1, $bg, $window, #000000, $accent, $bg, $accent, $link2, $surface, $bg, $surface, $fg, $muted, $accent"; }
    mkdir -p "$HOME/.config/qt6ct/colors"
    cat > "$HOME/.config/qt6ct/colors/wal.conf" <<COLORS
[ColorScheme]
active_colors=$(row "$fg")
disabled_colors=$(row "$muted")
inactive_colors=$(row "$fg")
COLORS
    cat > "$HOME/.config/qt6ct/qt6ct.conf" <<CONF
[Appearance]
color_scheme_path=$HOME/.config/qt6ct/colors/wal.conf
custom_palette=true
icon_theme=Adwaita
standard_dialogs=default
style=Fusion

[Fonts]
fixed="JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="JetBrains Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
CONF
fi
