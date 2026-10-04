#!/usr/bin/env bash
# Symlink the repo into ~/.config and ~/.local/bin. Existing real files are moved to *.bak.
# Usage: ./install.sh [--dry-run]
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dry=0
[[ "${1:-}" == "--dry-run" ]] && dry=1

run() { if ((dry)); then echo "+ $*"; else "$@"; fi; }

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

for dir in hypr waybar kitty wofi wlogout mako; do
    link "$repo/$dir" "$HOME/.config/$dir"
done

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
