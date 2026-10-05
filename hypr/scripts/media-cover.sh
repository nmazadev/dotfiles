#!/bin/bash
# Album art for the waybar music pill, and a "now playing" notification on each new
# song. Follows Spotify (no polling): downloads the cover to
# ~/.cache/media-cover/current.jpg when it changes, tells waybar to refresh its image
# module (signal 9) and calls now-playing.sh when the song changes. Removes the cover
# when Spotify stops. Started by autostart.lua.

cache="$HOME/.cache/media-cover"
mkdir -p "$cache"
rm -f "$cache/current.jpg"

while true; do
    last_url="" last_song=""
    # one line per change: cover url <tab> title <tab> artist (empty when Spotify closes)
    playerctl -p spotify --follow metadata --format $'{{mpris:artUrl}}\t{{title}}\t{{artist}}' 2>/dev/null |
    while IFS=$'\t' read -r url title artist; do
        # older Spotify builds report open.spotify.com/image/<id>
        url=${url/https:\/\/open.spotify.com\/image\//https:\/\/i.scdn.co\/image\/}
        if [ "$url" != "$last_url" ]; then
            if [ -n "$url" ] && curl -fsSL --max-time 10 "$url" -o "$cache/next.jpg"; then
                mv "$cache/next.jpg" "$cache/current.jpg"
            else
                rm -f "$cache/current.jpg"
            fi
            last_url=$url
            pkill -RTMIN+9 -x waybar
        fi
        if [ -n "$title" ] && [ "$title|$artist" != "$last_song" ]; then
            last_song="$title|$artist"
            "$HOME/.config/hypr/scripts/now-playing.sh"
        fi
    done
    # playerctl exits when it can't reach D-Bus yet; try again shortly
    rm -f "$cache/current.jpg"
    pkill -RTMIN+9 -x waybar
    sleep 5
done
