#!/bin/bash
#   _ _ _ _____ __ __ _____ _____ _____ 
#  | | | |  _  |  |  | __  |  _  | __  |
#  | | | |     |_   _| __ -|     |    -|
#  |_____|__|__| |_| |_____|__|__|__|__|  LAUNCH
#
#  by Bina

# One launch at a time: login runs this from startup.sh and the monitor hotplug
# script at once, and two overlapping launches each started a waybar
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-launch.lock"
flock 9

# terminate running instances
killall -q waybar

# wait until processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 0.1; done

# launch main
# 9>&-: waybar must not inherit the lock, or it would hold it for its whole life
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css 9>&- &

