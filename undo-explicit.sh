#!/usr/bin/env bash
# Undo the "mark explicit" step an earlier install-packages.sh had: set the packages
# it lists back to "installed as a dependency", but only those another installed
# package still requires. The rest stay explicit, because as dependencies nothing
# would need them and an orphan cleanup (pacman -Qdt / -Rns) would remove them.
# Shows the list and asks before changing anything.
# Usage: ./undo-explicit.sh [--dry-run]
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$repo/lib.sh"
parse_args "$@"

# every package named on an "install ..." line of install-packages.sh
mapfile -t pkgs < <(sed -e ':a' -e '/\\$/N; s/\\\n//; ta' "$repo/install-packages.sh" |
    sed -n 's/^[[:space:]]*install \(.*\)$/\1/p' | tr -s ' \t' '\n' | grep -v '^$' | sort -u)

to_deps=() keep=()
for p in "${pkgs[@]}"; do
    pacman -Qq "$p" >/dev/null 2>&1 || continue          # not installed here
    reason=$(LC_ALL=C pacman -Qi "$p" | sed -n 's/^Install Reason *: //p')
    [[ $reason == Explicitly* ]] || continue               # already a dependency
    required=$(LC_ALL=C pacman -Qi "$p" | sed -n 's/^Required By *: //p')
    if [[ $required != None ]]; then
        to_deps+=("$p")
    else
        keep+=("$p")
    fi
done

echo ":: Back to 'installed as a dependency' (something still requires them):"
((${#to_deps[@]})) && printf '   %s\n' "${to_deps[@]}" || echo "   none"
echo ":: Left explicit (nothing requires them; as dependencies they'd be removable):"
((${#keep[@]})) && printf '   %s\n' "${keep[@]}" || echo "   none"

((${#to_deps[@]})) || exit 0
if ((dry)); then
    echo "(dry run: nothing changed)"
    exit 0
fi
read -r -p "Mark the first list as dependencies? [y/N] " answer </dev/tty
[[ $answer == [yY]* ]] || { echo "Cancelled."; exit 0; }
sudo pacman -D --asdeps "${to_deps[@]}"
