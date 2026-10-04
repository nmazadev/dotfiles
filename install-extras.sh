#!/usr/bin/env bash
# Install the lidm login manager (AUR via paru), its theme, and enable it.
# Usage: ./install-extras.sh [--dry-run]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_args "$@"
require_paru

# lidm needs a service provider; EndeavourOS uses systemd. It is installed
# first so paru never asks which provider of lidm-service to use.
service_provider=lidm-systemd

run paru -S --needed "$service_provider"
run paru -S --needed lidm

# Theme; the existing config is kept as /etc/lidm.ini.bak
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
run sudo install -b -S .bak -m 644 "$repo/lidm/lidm.ini" /etc/lidm.ini

# Unit name comes from the package; fall back to the usual one
unit=$(pacman -Ql "$service_provider" 2>/dev/null | awk '/\.service$/ { n = split($2, a, "/"); print a[n]; exit }' || true)
unit=${unit:-lidm.service}

# lidm replaces the getty on tty1. Takes effect on the next boot, so the
# current session is left alone.
run sudo systemctl disable getty@tty1.service
run sudo systemctl enable "$unit"

echo
echo "Done. Reboot to start lidm."
echo "Rollback: from another tty run: sudo systemctl disable ${unit%.service} && sudo systemctl enable getty@tty1"
