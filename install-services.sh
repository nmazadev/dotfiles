#!/usr/bin/env bash
# Enable the system and user services the desktop relies on, set up zram, the
# shell, and create the directories it expects.
# Usage: ./install-services.sh [--dry-run]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_args "$@"

run sudo systemctl enable --now NetworkManager.service bluetooth.service power-profiles-daemon.service

# SSD trim and weekly package cache cleanup (keeps the last 3 versions)
run sudo systemctl enable --now fstrim.timer paccache.timer

# User units: --global enables them for every user, they start at next login.
# (hyprpolkitagent is started by autostart.lua: it needs graphical-session.target otherwise)
run sudo systemctl --global enable pipewire.socket pipewire-pulse.socket wireplumber.service

# zram: compressed swap in RAM, half the memory, zstd
zram=/etc/systemd/zram-generator.conf
if [[ ! -f $zram ]]; then
    if ((dry)); then
        echo "+ write $zram ([zram0] zram-size = ram / 2, zstd) and start it"
    else
        printf '[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\n' | sudo tee "$zram" >/dev/null
        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service
    fi
fi

# zsh as login shell, with oh-my-zsh and the two plugins zsh/zshrc uses
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
    run chsh -s /usr/bin/zsh
fi
omz="$HOME/.oh-my-zsh"
[[ -d $omz ]] || run git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$omz"
for plugin in zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting; do
    dir="$omz/custom/plugins/${plugin#*/}"
    [[ -d $dir ]] || run git clone --depth 1 "https://github.com/$plugin.git" "$dir"
done

run xdg-user-dirs-update

# wallpaper.sh picks images from here
run mkdir -p "$HOME/wallpapers"

echo
echo "Done. Put at least one image in ~/wallpapers: the next Hyprland login sets the"
echo "wallpaper and generates the pywal colors that waybar and kitty use."
