#!/bin/bash
# Keep the screen awake while media is playing: music, videos, calls/meetings.
# hypridle honors systemd idle inhibitors, so while any audio stream plays (or an
# app records the microphone, like Discord or a meeting) this holds one. When
# everything is quiet it lets go and the normal dim/lock/screen-off timers apply.
# Started once from autostart.lua.

interval=15
pid=""

# apps that read audio without being "media": visualizers and mixers
ignore='^(cava|pavucontrol|PulseAudio Volume Control|wiremix|waybar)$'

active() {
    local streams
    streams=$( { pactl -f json list sink-inputs; pactl -f json list source-outputs; } 2>/dev/null \
        | jq -r '.[] | select(.corked == false) | .properties["application.name"] // ""')
    [ -n "$(grep -Ev "$ignore" <<<"$streams" | grep -v '^$')" ]
}

release() { [ -n "$pid" ] && kill "$pid" 2>/dev/null; pid=""; }
trap 'release; exit 0' INT TERM

while true; do
    if active; then
        if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
            systemd-inhibit --what=idle --who=media-inhibit --why="Media is playing" sleep infinity &
            pid=$!
        fi
    else
        release
    fi
    sleep "$interval"
done
