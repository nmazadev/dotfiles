#!/usr/bin/env bash
# Install every package the dotfiles need (official repos + AUR via paru),
# plus GPU drivers for whatever GPUs are detected.
# Usage: ./install-packages.sh [--dry-run]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
parse_args "$@"
ensure_paru

# --needed skips packages that are already there, but those may be installed only as
# another package's dependency (e.g. by a previous setup) and get removed together
# with it later (cleanup-meowrch.sh lost grim that way). Mark them explicit.
install() {
    run paru -S --needed "$@"
    run sudo pacman -D --asexplicit "$@" || true
}

install base-devel git xdg-utils xdg-user-dirs zsh pacman-contrib micro vim

# Desktop
install hyprland hypridle hyprlock waybar kitty wofi wlogout awww yazi xdg-terminal-exec

# Helpers used by binds, waybar and the wallpaper script
install grim slurp wl-clipboard satty brightnessctl playerctl python-pywal imagemagick jq libnotify mako \
    btop bluetui wiremix blueman cava pavucontrol glow fastfetch zoxide

# Fonts, icons and cursor
install ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji adwaita-icon-theme rose-pine-hyprcursor

# Audio, bluetooth, network
install pipewire pipewire-pulse pipewire-alsa wireplumber bluez bluez-utils networkmanager

# Laptop power profiles, compressed swap in RAM, keyring for the shell's ssh agent
install power-profiles-daemon zram-generator gnome-keyring

# Portals (screen sharing, file dialogs) and the polkit agent (auth dialogs)
install xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent qt6-wayland qt6ct

if has_gpu intel; then
    echo ":: Intel GPU detected"
    install mesa vulkan-intel intel-media-driver
fi

if has_gpu intel && has_gpu nvidia; then
    # GPU mode switching (TUI front end for envycontrol)
    install envycontrol envy-tui-bin
fi

if has_gpu nvidia; then
    echo ":: NVIDIA GPU detected"
    install nvidia-open nvidia-utils egl-wayland libva-nvidia-driver

    # Per the Hyprland wiki. Skipped if some file already sets modeset.
    if ! grep -qsr "nvidia_drm.*modeset" /etc/modprobe.d /usr/lib/modprobe.d; then
        if ((dry)); then
            echo '+ write /etc/modprobe.d/nvidia.conf: options nvidia_drm modeset=1 fbdev=1'
        else
            echo 'options nvidia_drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
        fi
    fi

    # EndeavourOS builds its initramfs with dracut; load the modules early
    if [[ -d /etc/dracut.conf.d ]] && ! grep -qs "nvidia_drm" /etc/dracut.conf.d/*.conf; then
        if ((dry)); then
            echo '+ write /etc/dracut.conf.d/nvidia.conf and run dracut-rebuild'
        else
            echo 'force_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' \
                | sudo tee /etc/dracut.conf.d/nvidia.conf >/dev/null
            sudo dracut-rebuild
        fi
    fi
fi
