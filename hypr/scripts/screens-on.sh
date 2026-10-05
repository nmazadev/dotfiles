#!/bin/bash
# Turn the screens back on after hypridle's dpms off or after suspend.
# A single "hyprctl dispatch" sometimes fails here (black screen that ignores
# keys/mouse while the session is still alive), so try each form until one
# works, retry once after the GPU had time to wake, and log what happened to
# ~/.cache/screens-on.log for debugging.

log="$HOME/.cache/screens-on.log"

on() {
    hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' 2>&1 | grep -qx ok && return 0
    hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = "on" }))' 2>&1 | grep -qx ok && return 0
    hyprctl dispatch dpms on 2>&1 | grep -qx ok
}

for attempt in 1 2 3; do
    if on; then
        echo "$(date '+%F %T') on (attempt $attempt)" >>"$log"
        break
    fi
    echo "$(date '+%F %T') failed (attempt $attempt)" >>"$log"
    sleep 1
done

# the dim listener may not have restored brightness if its resume was missed
brightnessctl -r >/dev/null 2>&1
