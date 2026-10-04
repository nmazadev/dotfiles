#!/usr/bin/env bash
# Enable the system and user services the desktop relies on, and create the
# directories it expects.
# Usage: ./install-services.sh [--dry-run]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_args "$@"

run sudo systemctl enable --now NetworkManager.service bluetooth.service

# User units: --global enables them for every user, they start at next login
run sudo systemctl --global enable pipewire.socket pipewire-pulse.socket wireplumber.service hyprpolkitagent.service

run xdg-user-dirs-update

# wallpaper.sh picks images from here
run mkdir -p "$HOME/wallpapers"

echo
echo "Done. Put at least one image in ~/wallpapers: the next Hyprland login sets the"
echo "wallpaper and generates the pywal colors that waybar and kitty use."
