#!/usr/bin/env bash
# Symlink the repo into ~/.config and ~/.local/bin. Existing real files are moved to *.bak.
# Usage: ./install.sh [--dry-run]
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$repo/lib.sh"
parse_args "$@"

link() { # link <source> <target>
    local src="$1" dst="$2"
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "ok      $dst"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        echo "backup  $dst -> $dst.bak"
        run rm -rf "$dst.bak"
        run mv "$dst" "$dst.bak"
    fi
    echo "link    $dst -> $src"
    run mkdir -p "$(dirname "$dst")"
    run ln -sfn "$src" "$dst"
}

for dir in hypr waybar kitty wofi wlogout mako fastfetch; do
    link "$repo/$dir" "$HOME/.config/$dir"
done

# GTK apps (pavucontrol, blueman): link the settings only; gtk.css is built by gtk-theme.sh
for f in gtk-3.0/settings.ini gtk-4.0/settings.ini; do
    link "$repo/$f" "$HOME/.config/$f"
done

# zsh, and faster AUR builds (MAKEFLAGS for makepkg/paru)
link "$repo/zsh/zshrc" "$HOME/.zshrc"
link "$repo/pacman/makepkg.conf" "$HOME/.config/pacman/makepkg.conf"

# vim: the vimrc and the colorscheme that uses the terminal palette
link "$repo/vim/vimrc" "$HOME/.vimrc"
link "$repo/vim/colors/cozy.vim" "$HOME/.vim/colors/cozy.vim"

# pywal templates: link the files only, ~/.config/wal/templates may hold others
for tpl in "$repo"/wal/templates/*; do
    link "$tpl" "$HOME/.config/wal/templates/$(basename "$tpl")"
done

# fixed color themes for theme.sh
for scheme in "$repo"/wal/colorschemes/*; do
    link "$scheme" "$HOME/.config/wal/colorschemes/$(basename "$scheme")"
done

for script in "$repo"/bin/*; do
    link "$script" "$HOME/.local/bin/$(basename "$script")"
done
