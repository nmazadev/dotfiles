#!/bin/bash
# Notifications that arrived while the screen is locked, for a hyprlock label
# (hypr/hyprlock.conf runs this every 2 s). While locked the compositor only draws
# the lock screen, so mako's own pop-ups can't show up there.
#
# On its first run for a lock (one hyprlock process) it remembers mako's newest
# notification id; after that it prints the newer ones, newest first: a count
# line, then "title: body" for the last few. Song changes (now-playing) are left
# out. Prints nothing while there are none.
#
# LOCK_ID overrides the hyprlock pid (for testing without locking).

lock=${LOCK_ID:-$(pidof -s hyprlock)}
[ -n "$lock" ] || exit 0

state="${XDG_RUNTIME_DIR:-/tmp}/lock-notifications.$lock"
shown=3   # how many to list
width=48  # characters per line

# visible pop-ups and expired ones (history), newest first, no duplicates
all=$( { makoctl list -j; makoctl history -j; } 2>/dev/null |
    jq -s 'add // [] | map(select(.app_name != "now-playing")) | unique_by(.id) | sort_by(-.id)')

newest=$(jq '.[0].id // 0' <<<"$all")
if [ ! -f "$state" ]; then
    # a new lock: start counting from here, and forget older locks
    rm -f "${XDG_RUNTIME_DIR:-/tmp}"/lock-notifications.*
    echo "$newest" > "$state"
fi
base=$(cat "$state")
# mako restarted (its ids start over): count from the start
[ "$newest" -lt "$base" ] && { base=0; echo 0 > "$state"; }

jq -r --argjson base "$base" --argjson shown "$shown" --argjson width "$width" '
    def clip: gsub("\\s+"; " ") | if length > $width then .[0:$width - 1] + "…" else . end;
    def esc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");
    map(select(.id > $base)) as $new
    | if ($new | length) == 0 then empty else
        "<b>\($new | length) new notification\(if ($new | length) > 1 then "s" else "" end)</b>",
        ($new[:$shown][] | (if .body != "" then "\(.summary): \(.body)" else .summary end) | clip | esc)
      end
' <<<"$all"
