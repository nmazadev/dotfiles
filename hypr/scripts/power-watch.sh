#!/bin/bash
# Power profiles (hypr/power.conf): one for plugged in, one for on battery. At login
# and whenever the charger is plugged in or out this builds hypridle's config from
# that profile (dim, lock and sleep times), restarts hypridle with it, and sets the
# power profile; on a plug/unplug it also sets the brightness. Follows the charger
# through udev events (no polling). No sudo needed for any of it.
# Usage: power-watch.sh          watch (started once by autostart.lua)
#        power-watch.sh apply    apply the current profile now (after editing power.conf)

hypr="$HOME/.config/hypr"
idle_conf="$HOME/.cache/hypridle.conf"

# ac or bat; a machine without a charger (desktop) counts as plugged in
state() {
    local s
    for s in /sys/class/power_supply/*; do
        [ "$(cat "$s/type" 2>/dev/null)" = Mains ] || continue
        [ "$(cat "$s/online" 2>/dev/null)" = 1 ] && { echo ac; return; }
        echo bat
        return
    done
    echo ac
}

# apply <ac|bat> [switch]: "switch" also sets the brightness and says so
apply() {
    local p=$1 dim dim_level lock suspend brightness profile
    source "$hypr/power.conf"
    dim=${p}_dim dim_level=${p}_dim_level lock=${p}_lock suspend=${p}_suspend
    brightness=${p}_brightness profile=${p}_profile
    dim=${!dim:-0} dim_level=${!dim_level:-10} lock=${!lock:-0} suspend=${!suspend:-0}
    brightness=${!brightness} profile=${!profile}

    # fill in the template, leaving out each listener whose time is 0
    mkdir -p "$(dirname "$idle_conf")"
    sed -e "s/@DIM@/$dim/" -e "s/@DIM_LEVEL@/$dim_level/" \
        -e "s/@LOCK@/$lock/" -e "s/@SUSPEND@/$suspend/" "$hypr/hypridle.template.conf" |
    awk '/^listener \{/ { block = $0; inside = 1; next }
         inside { block = block "\n" $0
                  if ($0 ~ /^\}/) { inside = 0; if (block !~ /timeout = 0\n/) print block }
                  next }
         { print }' > "$idle_conf.tmp" && mv -f "$idle_conf.tmp" "$idle_conf"

    pkill -x hypridle
    while pgrep -x hypridle >/dev/null; do sleep 0.1; done
    hypridle -c "$idle_conf" >/dev/null 2>&1 &
    disown

    [ -n "$profile" ] && powerprofilesctl set "$profile" 2>/dev/null

    if [ "$2" = switch ]; then
        [ -n "$brightness" ] && brightnessctl -q set "$brightness%"
        local where="On battery" sleep="never sleeps"
        [ "$p" = ac ] && where="Plugged in"
        ((suspend > 0)) && sleep="sleeps after $((suspend / 60)) min"
        notify-send -t 3000 "$where" "${profile:-power profile unchanged}, $sleep"
    fi
}

if [ "$1" = apply ]; then
    apply "$(state)" switch
    exit 0
fi

# one watcher at a time
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/power-watch.lock"
flock -n 9 || exit 0

last=$(state)
apply "$last" 9>&-
udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null |
while read -r _; do
    now=$(state)
    [ "$now" = "$last" ] && continue
    last=$now
    apply "$now" switch 9>&-
done
