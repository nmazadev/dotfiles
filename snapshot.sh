#!/usr/bin/env bash
# Read-only btrfs snapshots of / and /home (separate subvolumes on EndeavourOS, so
# each gets its own). Instant, and no extra space until files change.
# Usage:
#   ./snapshot.sh [label] [--dry-run]   take one, named <label>-<date> (default label: manual)
#   ./snapshot.sh --list                show existing ones
# Snapshots land in /.snapshots and /home/.snapshots.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

label=manual list=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry=1 ;;
        --list) list=1 ;;
        -*) echo "unknown option: $arg" >&2; exit 1 ;;
        *) label=$arg ;;
    esac
done

fstype() { findmnt -no FSTYPE --target "$1"; }
mounts=(/)
# /home on its own subvolume needs its own snapshot
if [[ $(fstype /home) == btrfs && $(findmnt -no SOURCE /home) != "$(findmnt -no SOURCE /)" ]]; then
    mounts+=(/home)
fi

if ((list)); then
    for mnt in "${mounts[@]}"; do
        dir="${mnt%/}/.snapshots"
        echo "$dir:"
        if [[ -d $dir ]]; then ls -1 "$dir" | sed 's/^/   /'; else echo "   (none)"; fi
    done
    exit 0
fi

if [[ $(fstype /) != btrfs ]]; then
    echo "/ is not btrfs: snapshots are not possible here" >&2
    exit 1
fi

name="$label-$(date +%Y-%m-%d_%H-%M)"
for mnt in "${mounts[@]}"; do
    dir="${mnt%/}/.snapshots"
    run sudo mkdir -p "$dir"
    run sudo btrfs subvolume snapshot -r "$mnt" "$dir/$name"
done
echo ":: snapshot $name of ${mounts[*]}"
