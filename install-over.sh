#!/usr/bin/env bash
# Install the dotfiles on top of an existing setup (e.g. meowrch) without wiping it.
# Takes read-only btrfs snapshots of / and /home before (fallback) and after (milestone),
# sets aside what would override this setup, and runs bootstrap.sh in between.
# Nothing under ~/.config/Cursor or ~/.cursor is touched.
# Usage: ./install-over.sh [--dry-run]
set -euo pipefail
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$repo/lib.sh"
parse_args "$@"

stamp=$(date +%Y-%m-%d_%H-%M)
fstype() { findmnt -no FSTYPE --target "$1"; }

echo ":: Current system"
echo "   /      $(fstype /)"
echo "   /home  $(fstype /home)"
dm=$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)
echo "   display manager: $([[ -n $dm ]] && basename "$dm" || echo none)"
for d in "$HOME/.config/Cursor" "$HOME/.cursor"; do
    [[ -e $d ]] && echo "   found $d (left untouched)"
done

# snapshot <label>: read-only btrfs snapshots of / and /home (separate subvolumes on
# EndeavourOS, so each needs its own). Instant, and no extra space until files change.
snapshots=()
snapshot() {
    local label=$1 mnt dir
    [[ $(fstype /) == btrfs ]] || return 0
    for mnt in / /home; do
        [[ $(fstype "$mnt") == btrfs ]] || continue
        dir="${mnt%/}/.snapshots"
        run sudo mkdir -p "$dir"
        run sudo btrfs subvolume snapshot -r "$mnt" "$dir/$label-$stamp"
        snapshots+=("$dir/$label-$stamp")
        # /home on the same subvolume as /: one snapshot covers both
        if [[ $(findmnt -no SOURCE /home) == "$(findmnt -no SOURCE /)" ]]; then break; fi
    done
}

# 1. fallback: how everything was before
if [[ $(fstype /) == btrfs ]]; then
    echo ":: Snapshot before (fallback)"
    snapshot pre-dotfiles
else
    echo ":: / is not btrfs, skipping snapshots (make a backup first if you need one)"
fi

# 2. things from the previous setup that would compete with this one
echo ":: Checking for conflicts"
for daemon in swaync dunst; do
    if pacman -Q "$daemon" >/dev/null 2>&1; then
        echo "   $daemon is installed: it can take notifications away from mako."
        echo "   Remove it with: sudo pacman -Rns $daemon"
    fi
done
# Set aside (renamed to *.bak) what would override this setup:
#   ~/.zshenv that sets ZDOTDIR, + ~/.config/zsh   zsh would read that folder, not ~/.zshrc
#   ~/.config/environment.d/60-meowrch.conf         session env (ZDOTDIR, TERM, ...)
#   ~/.config/uwsm                                  the previous UWSM environment
aside=()
if [[ -f $HOME/.zshenv ]] && grep -q ZDOTDIR "$HOME/.zshenv"; then
    aside+=("$HOME/.zshenv" "$HOME/.config/zsh")
fi
aside+=("$HOME/.config/environment.d/60-meowrch.conf" "$HOME/.config/uwsm")
for path in "${aside[@]}"; do
    if [[ -e $path && ! -L $path ]]; then
        echo "   setting aside ${path/#$HOME/\~}"
        run rm -rf "$path.bak"
        run mv "$path" "$path.bak"
    fi
done
# the other display manager is switched to lidm by install-extras.sh

# 3. the regular install; replaced configs are kept as *.bak
echo ":: Installing"
"$repo/bootstrap.sh" "$@"

# 4. milestone: the new setup, before anything of the old one is removed
echo ":: Snapshot after (milestone)"
snapshot post-dotfiles

echo
echo "Done. Reboot and pick the Hyprland session in lidm (zsh is now the login shell)."
echo "Once it works, ./cleanup-meowrch.sh removes what meowrch left behind."
if ((${#snapshots[@]})); then
    echo
    echo "Snapshots (pre = how it was, post = right after this install):"
    printf '   %s\n' "${snapshots[@]}"
    echo "Restore a file or folder, e.g. an old config:"
    echo "   cp -a /home/.snapshots/pre-dotfiles-$stamp/$USER/.config/hypr ~/.config/hypr.old"
    echo "Delete them once you are happy:"
    echo "   sudo btrfs subvolume delete ${snapshots[*]}"
fi
