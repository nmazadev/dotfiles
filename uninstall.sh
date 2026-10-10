#!/usr/bin/env bash
# Undo install.sh and the login part of install-extras.sh: remove the links into this
# repo (putting back the *.bak files install.sh made) and the lidm theme, console font
# and quiet session, and go back to the text login on tty1.
# Packages, services, zsh/oh-my-zsh, ~/wallpapers and ~/.cache/wal are kept.
# Lists everything first and asks before changing anything.
# Usage: ./uninstall.sh [--dry-run]
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$repo/lib.sh"
parse_args "$@"

# links into the repo, found rather than listed so this never falls behind install.sh
links=()
while IFS= read -r -d '' l; do
    links+=("$l")
done < <(find "$HOME/.config" "$HOME/.local/bin" "$HOME/.vim/colors" -maxdepth 3 \
             -lname "$repo/*" -print0 2>/dev/null || true)
for l in "$HOME/.zshrc" "$HOME/.vimrc"; do
    [[ -L $l && $(readlink "$l") == "$repo/"* ]] && links+=("$l")
done
# btop's theme points at pywal's output, not the repo
btop_theme="$HOME/.config/btop/themes/wal.theme"
[[ -L $btop_theme && $(readlink "$btop_theme") == "$HOME/.cache/wal/btop.theme" ]] && links+=("$btop_theme")

# login (sudo): only what is actually there
dropin=/etc/systemd/system/lidm.service.d/theme.conf
system_files=()
for f in "$dropin" /usr/local/bin/hyprland-quiet /usr/local/bin/lidm-console-font \
         /usr/local/share/wayland-sessions/hyprland-quiet.desktop; do
    [[ -e $f ]] && system_files+=("$f")
done
lidm_ini=0; [[ -f /etc/lidm.ini.bak ]] && lidm_ini=1
# only the font install-extras.sh set, so one picked by hand stays
font=0; grep -qx 'FONT=ter-v28n' /etc/vconsole.conf 2>/dev/null && font=1
dm=$(basename "$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null)" 2>/dev/null || true)
lidm=0; [[ $dm == lidm*.service ]] && lidm=1

if ((${#links[@]} == 0 && ${#system_files[@]} == 0 && !lidm_ini && !font && !lidm)); then
    echo "Nothing to undo."
    exit 0
fi

if ((${#links[@]})); then
    echo ":: Links to remove (a *.bak next to one is moved back):"
    for l in "${links[@]}"; do
        if [[ -e $l.bak || -L $l.bak ]]; then
            echo "   ${l/#$HOME/\~}  (restores ${l/#$HOME/\~}.bak)"
        else
            echo "   ${l/#$HOME/\~}"
        fi
    done
fi
if ((${#system_files[@]})); then
    echo ":: Files to delete (sudo):"
    printf '   %s\n' "${system_files[@]}"
fi
((lidm_ini)) && echo ":: /etc/lidm.ini: the original comes back from /etc/lidm.ini.bak"
((font)) && echo ":: /etc/vconsole.conf: FONT=ter-v28n removed (console back to the default font)"
((lidm)) && echo ":: Login: $dm disabled, getty@tty1 (text login) enabled, from the next boot"
echo
echo "Kept: packages (remove them with paru -Rns if you like), services, zsh and oh-my-zsh,"
echo "~/wallpapers, ~/.cache/wal and btop's color_theme setting."

if ((dry)); then
    echo "(dry run: nothing changed)"
    exit 0
fi
read -r -p "Undo all of the above? [y/N] " answer </dev/tty
[[ $answer == [yY]* ]] || { echo "Cancelled."; exit 0; }

for l in "${links[@]}"; do
    rm -f -- "$l"
    if [[ -e $l.bak || -L $l.bak ]]; then
        mv -- "$l.bak" "$l"
    fi
done

if ((${#system_files[@]})); then
    sudo rm -f -- "${system_files[@]}"
    sudo rmdir --ignore-fail-on-non-empty "$(dirname "$dropin")" 2>/dev/null || true
fi
((lidm_ini)) && sudo mv -f /etc/lidm.ini.bak /etc/lidm.ini
((font)) && sudo sed -i '/^FONT=ter-v28n$/d' /etc/vconsole.conf
if ((lidm)); then
    sudo systemctl disable "$dm"
    sudo systemctl enable getty@tty1.service
fi
((${#system_files[@]} || lidm)) && sudo systemctl daemon-reload

echo
echo "Done. This session has lost its config links: log out or reboot now."
echo "Back in later with ./install.sh (and ./install-extras.sh for lidm)."
