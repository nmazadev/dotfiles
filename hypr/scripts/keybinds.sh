#!/bin/bash
# Hotkeys menu (SUPER + /): every Hyprland shortcut with its description, read live
# from Hyprland, so it always matches hypr/binds.lua. Type to search.

hyprctl binds -j | jq -r '
    def mods:
        [ (if (.modmask / 64 | floor) % 2 == 1 then "SUPER" else empty end),
          (if (.modmask / 4  | floor) % 2 == 1 then "CTRL"  else empty end),
          (if (.modmask / 8  | floor) % 2 == 1 then "ALT"   else empty end),
          (if  .modmask % 2 == 1                then "SHIFT" else empty end) ];
    def keyname:
        { "mouse:272": "left mouse", "mouse:273": "right mouse",
          "mouse_down": "scroll down", "mouse_up": "scroll up",
          "RETURN": "Return", "TAB": "Tab", "slash": "/",
          "XF86AudioRaiseVolume": "volume up key", "XF86AudioLowerVolume": "volume down key",
          "XF86AudioMute": "mute key", "XF86AudioMicMute": "mic mute key",
          "XF86AudioPlay": "play key", "XF86AudioPause": "pause key",
          "XF86AudioNext": "next track key", "XF86AudioPrev": "previous track key",
          "XF86AudioStop": "stop key",
          "XF86MonBrightnessUp": "brightness up key", "XF86MonBrightnessDown": "brightness down key" }[.] // . ;
    .[] | select(.description != "")
        | ((mods + [.key | keyname]) | join(" + ")) as $keys
        | "\($keys)\t\(.description)"' |
    awk -F'\t' '!seen[$0]++ { printf "%-28s %s\n", $1, $2 }' |
    wofi --dmenu --prompt "hotkeys" --style "$HOME/.cache/wal/wofi.css" \
        --width 720 --height 520 --insensitive >/dev/null
