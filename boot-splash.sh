#!/usr/bin/env bash
# Boot splash: Plymouth with "bgrt-nologo", the built-in "bgrt" theme (the firmware/MSI
# logo with a small spinner, and a clean graphical disk-unlock prompt) minus the distro
# logo that bgrt shows at the bottom.
# Installs plymouth, builds and selects that theme, adds "quiet splash" to the kernel command line
# (GRUB) and rebuilds the initramfs. Takes a snapshot first (snapshot.sh) when / is btrfs.
# Usage: ./boot-splash.sh [--dry-run]
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$repo/lib.sh"
parse_args "$@"

if [[ $(findmnt -no FSTYPE /) == btrfs ]]; then
    "$repo/snapshot.sh" pre-splash "$@"
fi

run sudo pacman -S --needed --noconfirm plymouth

# bgrt-nologo: bgrt's settings with its own image folder, holding the spinner images
# without watermark.png (the Arch logo). Built from the installed files, in its own
# folder so plymouth updates don't overwrite it.
themes=/usr/share/plymouth/themes
theme=bgrt-nologo
if ((dry)); then
    echo "+ build $themes/$theme from bgrt + spinner images without watermark.png"
else
    sudo mkdir -p "$themes/$theme"
    sudo find "$themes/spinner" -maxdepth 1 -name '*.png' ! -name watermark.png -exec cp -t "$themes/$theme" {} +
    sed -e "s#^ImageDir=.*#ImageDir=$themes/$theme#" -e 's/^Name=BGRT$/Name=BGRT (no logo)/' \
        "$themes/bgrt/bgrt.plymouth" | sudo tee "$themes/$theme/$theme.plymouth" >/dev/null
fi
run sudo plymouth-set-default-theme "$theme"

# kernel command line: GRUB is what EndeavourOS uses here
grub=/etc/default/grub
if [[ -f $grub ]]; then
    line=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$grub" || true)
    missing=()
    for opt in quiet splash; do
        [[ " ${line//[\'\"]/ } " == *" $opt "* ]] || missing+=("$opt")
    done
    if ((${#missing[@]})); then
        echo ":: adding '${missing[*]}' to GRUB_CMDLINE_LINUX_DEFAULT (backup: $grub.bak)"
        run sudo cp "$grub" "$grub.bak"
        # append inside the existing quotes, whichever kind they are
        run sudo sed -i -E "s/^(GRUB_CMDLINE_LINUX_DEFAULT=['\"])(.*)(['\"])$/\\1\\2 ${missing[*]}\\3/" "$grub"
    fi
    run sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "No $grub: add 'quiet splash' to your boot loader's kernel options by hand." >&2
fi

# initramfs: mkinitcpio needs the plymouth hook; dracut picks the module up by itself
if grep -qs '^HOOKS=' /etc/mkinitcpio.conf && ! command -v dracut-rebuild >/dev/null; then
    if ! grep -qs '^HOOKS=.*plymouth' /etc/mkinitcpio.conf; then
        echo ":: adding the plymouth hook to /etc/mkinitcpio.conf"
        run sudo sed -i -E 's/^(HOOKS=\(.*\b(systemd|udev)\b)/\1 plymouth/' /etc/mkinitcpio.conf
    fi
    run sudo mkinitcpio -P
elif command -v dracut-rebuild >/dev/null; then
    if ! grep -qs plymouth /etc/dracut.conf.d/*.conf; then
        if ((dry)); then
            echo '+ write /etc/dracut.conf.d/plymouth.conf: add_dracutmodules+=" plymouth "'
        else
            echo 'add_dracutmodules+=" plymouth "' | sudo tee /etc/dracut.conf.d/plymouth.conf >/dev/null
        fi
    fi
    run sudo dracut-rebuild
fi

echo
echo "Done. Reboot to see the splash. To undo: restore $grub.bak, run grub-mkconfig,"
echo "remove plymouth (sudo pacman -Rns plymouth) and rebuild the initramfs."
