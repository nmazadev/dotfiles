#!/bin/bash
# "Now playing" notification with the album cover, sent by media-cover.sh on each
# new song. mako shows these bigger (see mako/config).

title=$(playerctl -p spotify metadata title 2>/dev/null) || exit 0
artist=$(playerctl -p spotify metadata artist 2>/dev/null)
album=$(playerctl -p spotify metadata album 2>/dev/null)
cover="$HOME/.cache/media-cover/current.jpg"

args=(-a now-playing -t 5000 -h string:x-canonical-private-synchronous:now-playing)
[ -f "$cover" ] && args+=(-i "$cover")
notify-send "${args[@]}" "$title" "$artist${album:+\n$album}"
