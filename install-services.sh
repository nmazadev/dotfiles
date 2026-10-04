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

# Screen sharing: a portal that was already running doesn't see a newly installed
# xdg-desktop-portal-hyprland until it restarts
run systemctl --user try-restart xdg-desktop-portal.service

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

# GTK4 apps and the portal read the theme from gsettings; a previous setup may have
# left its own there. Adwaita + dark, with the colors coming from gtk-theme.sh
for kv in "gtk-theme Adwaita" "icon-theme Adwaita" "color-scheme prefer-dark"; do
    run gsettings set org.gnome.desktop.interface ${kv% *} "${kv#* }"
done

# wallpaper.sh picks images from here; the repo's wallpapers are copied in
# (not linked) so you can add or remove your own freely
run mkdir -p "$HOME/wallpapers"
for wp in "$(dirname "${BASH_SOURCE[0]}")"/wallpapers/*; do
    [[ -f $wp && ! -e "$HOME/wallpapers/$(basename "$wp")" ]] && run cp "$wp" "$HOME/wallpapers/"
done

echo
echo "Done. The next Hyprland login sets the wallpaper from ~/wallpapers (add your own"
echo "images there any time; SUPER+W picks one at random)."
