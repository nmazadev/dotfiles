#!/bin/bash
# Build the GTK3 and GTK4 user stylesheets from the current theme colors.
# GTK does not follow @import through our symlinks, so the colors and the repo's
# extra styling are concatenated into real files. Running apps need a restart.

repo=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../.." && pwd)
colors="$HOME/.cache/wal/colors-gtk.css"
[ -f "$colors" ] || exit 0

for v in 3.0 4.0; do
    mkdir -p "$HOME/.config/gtk-$v"
    cat "$colors" "$repo/gtk-$v/extra.css" > "$HOME/.config/gtk-$v/gtk.css"
done
