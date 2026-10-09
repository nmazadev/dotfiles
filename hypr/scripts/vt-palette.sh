#!/bin/bash
# Console (tty) palette from the current pywal colours, for the lidm login screen.
# Writes ~/.cache/wal/vtrgb in setvtrgb's format: three lines (red, green, blue),
# 16 comma-separated values each, one per palette slot. The lidm.service drop-in
# (lidm/theme.conf) loads it before lidm starts. Run by theme.sh.

cache="$HOME/.cache/wal"

jq -r '
    [.special.background, (.colors | .color1, .color2, .color3, .color4, .color5, .color6),
     .special.foreground, (.colors | .color8, .color9, .color10, .color11, .color12,
     .color13, .color14, .color15)]
    | map(ltrimstr("#") | [.[0:2], .[2:4], .[4:6]] | map(explode | map(
        if . >= 97 then . - 87 elif . >= 65 then . - 55 else . - 48 end) | .[0] * 16 + .[1]))
    | [map(.[0]), map(.[1]), map(.[2])]
    | map(map(tostring) | join(","))
    | .[]
' "$cache/colors.json" > "$cache/vtrgb"
