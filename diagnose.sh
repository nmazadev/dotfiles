#!/usr/bin/env bash
# Collect what's needed to debug the black screen after lock / screen off, and
# screenshots (Print) not opening satty. Writes a report you can paste back.
#
# Best moment to run it: WHILE the screen is stuck black. Switch to a text console
# with Ctrl+Alt+F3, log in, and run it there; the Hyprland session is still alive
# and the report captures its exact state. Ctrl+Alt+F1/F2 goes back.
#
# Usage: ./diagnose.sh [--wake] [--screenshot-test]
#   --wake             also try to turn the screens back on (several methods, logged)
#   --screenshot-test  also run grim on each monitor (only from inside Hyprland)
# Report: ~/diagnose-<date>.txt

wake=0 shot=0
for arg in "$@"; do
    case "$arg" in
        --wake) wake=1 ;;
        --screenshot-test) shot=1 ;;
        *) echo "usage: $0 [--wake] [--screenshot-test]" >&2; exit 1 ;;
    esac
done

out="$HOME/diagnose-$(date +%Y-%m-%d_%H-%M-%S).txt"
exec > >(tee "$out") 2>&1

section() { printf '\n===== %s =====\n' "$1"; }
run() { printf '$ %s\n' "$*"; "$@" 2>&1; echo; }

# From a text console the Hyprland variables aren't set: find the running instance
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
if [[ -z $HYPRLAND_INSTANCE_SIGNATURE ]]; then
    HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "$XDG_RUNTIME_DIR/hypr" 2>/dev/null | head -1)
    export HYPRLAND_INSTANCE_SIGNATURE
fi
hyprdir="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE"

section "when / where"
date
echo "tty: $(tty 2>/dev/null)  session type: ${XDG_SESSION_TYPE:-?}  instance: ${HYPRLAND_INSTANCE_SIGNATURE:-none}"
run uptime

section "versions"
run uname -r
for p in hyprland aquamarine hyprlock hypridle hyprutils hyprgraphics xdg-desktop-portal-hyprland \
         nvidia-open nvidia-open-dkms nvidia nvidia-utils mesa satty grim slurp wl-clipboard \
         lidm plymouth envycontrol; do
    pacman -Q "$p" 2>/dev/null
done
echo
command -v envycontrol >/dev/null && run envycontrol --query

section "kernel command line, nvidia modules"
run cat /proc/cmdline
for f in /sys/module/nvidia_drm/parameters/{modeset,fbdev}; do
    [[ -r $f ]] && echo "$f = $(<"$f")"
done
run sh -c 'grep -rhs "nvidia" /etc/modprobe.d /usr/lib/modprobe.d | grep -v "^#"'

section "GPUs and which one drives each screen"
run lspci -nnk -d ::0300
run lspci -nnk -d ::0302
for c in /sys/class/drm/card*-*; do
    [[ -r $c/status ]] || continue
    echo "$(basename "$c"): $(<"$c/status") enabled=$(<"$c/enabled") dpms=$(cat "$c/dpms" 2>/dev/null)"
done
for card in /sys/class/drm/card[0-9]; do
    echo "$(basename "$card"): vendor $(<"$card/device/vendor") driver $(basename "$(readlink -f "$card/device/driver")")"
done
for d in /sys/bus/pci/devices/*/; do
    [[ $(<"$d/vendor") == 0x10de && -r $d/power/runtime_status ]] &&
        echo "NVIDIA $(basename "$d") runtime power: $(<"$d/power/runtime_status")"
done
echo

section "Hyprland state"
if [[ -S $hyprdir/.socket.sock ]]; then
    run hyprctl monitors all
    run hyprctl configerrors
    run hyprctl getoption misc:key_press_enables_dpms
    run hyprctl getoption misc:mouse_move_enables_dpms
    echo "Print key binds:"
    hyprctl binds -j | jq -c '.[] | select(.key == "Print") | {modmask, key, description}'
    echo
else
    echo "no running Hyprland socket found in $XDG_RUNTIME_DIR/hypr"
fi

section "lock / idle state"
run pgrep -a 'hyprlock|hypridle|media-inhibit|mako|waybar'
run loginctl list-sessions
sid=$(loginctl list-sessions --no-legend 2>/dev/null | awk -v u="$USER" '$3 == u && $0 !~ /tty[0-9]/ {print $1; exit}')
[[ -n $sid ]] && run loginctl show-session "$sid" -p Type -p State -p Active -p LockedHint -p IdleHint
run systemd-inhibit --list --no-pager
run cat "$HOME/.config/hypr/hypridle.conf"
[[ -f $HOME/.cache/screens-on.log ]] && run tail -30 "$HOME/.cache/screens-on.log"

section "screenshot path (Print -> satty)"
run ls -l "$HOME/.local/bin/screenshot"
for t in grim slurp satty wl-copy jq; do
    printf '%-8s %s\n' "$t" "$(command -v "$t" || echo MISSING)"
done
run ls -l "$HOME/.cache/wal/satty.toml"
if [[ $shot == 1 && -n $WAYLAND_DISPLAY ]]; then
    tmp=$(mktemp -d)
    for o in $(hyprctl -j monitors | jq -r '.[].name'); do
        printf 'grim -o %s: ' "$o"
        if grim -o "$o" "$tmp/$o.png" 2>"$tmp/err"; then
            echo "ok ($(stat -c %s "$tmp/$o.png") bytes)"
        else
            echo "FAILED: $(cat "$tmp/err")"
        fi
    done
    printf 'satty --version: '; satty --version 2>&1
    rm -rf "$tmp"
    echo
elif [[ $shot == 1 ]]; then
    echo "(--screenshot-test needs to run inside Hyprland, not from a text console)"
fi

section "Hyprland log (errors and dpms / lock / output lines)"
log="$hyprdir/hyprland.log"
if [[ -f $log ]]; then
    grep -v libinput "$log" | grep -iE "err|fail|crash|dpms|lock|session|output|monitor|modeset|commit|page.?flip|egl|gbm|nvidia" | tail -150
    echo
    echo "--- last 40 lines ---"
    grep -v libinput "$log" | tail -40
else
    echo "no log at $log"
fi
[[ -f $HOME/.local/state/start-hyprland.log ]] && run tail -40 "$HOME/.local/state/start-hyprland.log"

section "kernel / driver messages this boot (drm, nvidia, i915)"
journalctl -k -b --no-pager 2>/dev/null | grep -iE "nvidia|nvrm|xid|drm|i915|flip|timeout|hang|gpu" | tail -80
echo

section "user journal: hyprlock, hypridle, portal errors this boot"
journalctl --user -b --no-pager 2>/dev/null | grep -iE "hyprlock|hypridle|satty|grim|portal.*(err|fail)|segfault|core dump" | tail -60
echo

section "crashes (coredumps) in the last 3 days"
coredumpctl list --since "-3d" --no-pager 2>/dev/null | grep -iE "hypr|satty|grim|waybar|aquamarine|kitty" || echo "none for hypr*/satty/grim/waybar"

section "previous boot: how it ended (if the last one froze)"
journalctl -b -1 -k --no-pager 2>/dev/null | grep -iE "nvidia|nvrm|xid|drm|flip|timeout" | tail -30
journalctl -b -1 --no-pager 2>/dev/null | tail -15

if ((wake)); then
    section "wake attempt"
    for m in 'hyprctl dispatch hl.dsp.dpms({ action = "on" })' \
             'hyprctl eval hl.dispatch(hl.dsp.dpms({ action = "on" }))'; do
        echo "\$ $m"
        if [[ $m == *eval* ]]; then
            hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = "on" }))' 2>&1
        else
            hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' 2>&1
        fi
        sleep 2
        hyprctl -j monitors all 2>/dev/null | jq -r '.[] | "  \(.name) dpms=\(.dpmsStatus) disabled=\(.disabled)"'
    done
    for c in /sys/class/drm/card*-*; do
        [[ -r $c/dpms ]] && echo "$(basename "$c") sysfs dpms: $(<"$c/dpms")"
    done
    run brightnessctl -r
    run brightnessctl
fi

echo
echo "Report saved to $out"
