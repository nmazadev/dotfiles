#!/usr/bin/env bash
# Install extra system packages (AUR via paru) and enable the lidm login manager.
# Usage: ./install-extras.sh [--dry-run]
set -euo pipefail

# Add more extras here
packages=(lidm lidm-systemd)

dry=0
[[ "${1:-}" == "--dry-run" ]] && dry=1

run() { if ((dry)); then echo "+ $*"; else "$@"; fi; }

if ! command -v paru >/dev/null; then
    echo "paru is required but not installed" >&2
    exit 1
fi

run paru -S --needed "${packages[@]}"

# Unit name comes from the package; fall back to the usual one
unit=$(pacman -Ql lidm-systemd 2>/dev/null | awk '/\.service$/ { n = split($2, a, "/"); print a[n]; exit }' || true)
unit=${unit:-lidm.service}

# lidm replaces the getty on tty1. Takes effect on the next boot, so the
# current session is left alone.
run sudo systemctl disable getty@tty1.service
run sudo systemctl enable "$unit"

echo
echo "Done. Reboot to start lidm."
echo "Rollback: from another tty run: sudo systemctl disable ${unit%.service} && sudo systemctl enable getty@tty1"
