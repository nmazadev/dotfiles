#!/usr/bin/env bash
# Remove what meowrch left behind once install-over.sh is in place and working.
# Only meowrch's desktop pieces (its bars, launchers, notification daemons, display
# manager, X11 window manager, theming tools) and its leftover configs/scripts.
# Apps you may use (firefox, code, discord, office, databases, ...) are left alone,
# and so is anything under ~/.config/Cursor and ~/.cursor.
# Shows everything first and asks before changing anything.
# Usage: ./cleanup-meowrch.sh [--dry-run]
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$repo/lib.sh"
parse_args "$@"

# meowrch packages this setup doesn't use (micro is kept on purpose)
candidates=(
    bspwm sxhkd polybar picom rofi rofimoji dunst swaync sddm betterlockscreen redshift
    xsettingsd mewline meowrch-settings meowrch-tools pawlette hotkeyhub-bin matugen starship
    lsd fish uwsm polkit-gnome xkb-switch wmname xorg-xsetroot feh maim clipnotify
    xdg-desktop-portal-wlr pokemon-colorscripts tela-circle-icon-theme-dracula
    bibata-cursor-theme-bin adw-gtk-theme firefox-gnome-theme qt5ct grimblast-git
)
packages=()
for p in "${candidates[@]}"; do
    pacman -Q "$p" >/dev/null 2>&1 && packages+=("$p")
done

# meowrch configs and home files
paths=()
for d in bspwm polybar rofi dunst swaync fish starship lsd mewline pawlette \
         meowrch-code-theme betterlockscreen redshift xsettingsd X11 qt5ct tg-config; do
    paths+=("$HOME/.config/$d")
done
paths+=("$HOME/.xinitrc" "$HOME/.xsession" "$HOME/.face.icon" "$HOME/.icons/default/index.theme")

# meowrch's helper scripts in ~/.local/bin (exact names; this repo's own scripts differ)
for s in battery.sh brightness.sh color-picker.sh color-scripts do-not-disturb.sh \
         gpu-detect-profile.sh kb-layout.sh media-active.sh media.sh playerinfo.sh \
         polkitkdeauth.sh resetxdgportal.sh rofi-menus screen-lock.sh screenshot.sh \
         set-wallpaper.sh system-info.py system-update.sh toggle-bar.sh untar-all.sh \
         unzip-all.sh uwsm-launcher.sh volume.sh; do
    paths+=("$HOME/.local/bin/$s")
done

# its user services
units=(battery-monitor.timer battery-monitor.service betterlockscreen-watch.path
       betterlockscreen-watch.service meowrch-hyprland-uwsm.service)
for u in "${units[@]}"; do
    paths+=("$HOME/.config/systemd/user/$u")
done

# the *.bak copies install.sh / install-over.sh made of the replaced configs
shopt -s nullglob
paths+=("$HOME"/.config/*.bak "$HOME"/.config/{gtk-3.0,gtk-4.0,micro,pacman,environment.d}/*.bak
        "$HOME"/.config/micro/colorschemes/*.bak "$HOME"/.config/wal/*/*.bak
        "$HOME"/.vim/colors/*.bak "$HOME"/.local/bin/*.bak
        "$HOME/.zshrc.bak" "$HOME/.vimrc.bak" "$HOME/.zshenv.bak")
shopt -u nullglob

existing=()
for p in "${paths[@]}"; do
    [[ -e $p || -L $p ]] && existing+=("$p")
done

if ((${#packages[@]} == 0 && ${#existing[@]} == 0)); then
    echo "Nothing from meowrch left to remove."
    exit 0
fi

echo ":: Packages to remove (with their unused dependencies):"
((${#packages[@]})) && printf '   %s\n' "${packages[@]}" || echo "   none"
echo ":: Files and folders to delete:"
((${#existing[@]})) && printf '   %s\n' "${existing[@]/#$HOME/\~}" || echo "   none"
echo
echo "Tip: install-over.sh took a 'post-dotfiles' snapshot; anything here can be copied back from it."

if ((dry)); then
    echo "(dry run: nothing changed)"
    exit 0
fi
read -r -p "Remove all of the above? [y/N] " answer </dev/tty
[[ $answer == [yY]* ]] || { echo "Cancelled."; exit 0; }

for u in "${units[@]}"; do
    systemctl --user disable --now "$u" >/dev/null 2>&1 || true
done
systemctl --user daemon-reload

for p in "${existing[@]}"; do
    rm -rf -- "$p"
done

# one package at a time, so one that something else still needs doesn't block the rest
for p in "${packages[@]}"; do
    if ! sudo pacman -Rns --noconfirm "$p" >/dev/null 2>&1; then
        echo "   kept $p (another package depends on it)"
    fi
done

echo "Done."
