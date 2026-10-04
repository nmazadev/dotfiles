# Shared helpers, sourced by the install scripts. Not meant to be run.
# Callers pass their arguments through `parse_args "$@"` to get --dry-run.

dry=0
parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run) dry=1 ;;
            *) echo "unknown option: $arg" >&2; exit 1 ;;
        esac
    done
}

run() { if ((dry)); then echo "+ $*"; else "$@"; fi; }

# ensure_paru: install paru if it is missing. EndeavourOS ships it in its own repo;
# on plain Arch it is built from the AUR (paru-bin).
ensure_paru() {
    command -v paru >/dev/null && return 0
    echo ":: paru not found, installing it"
    if pacman -Si paru >/dev/null 2>&1; then
        run sudo pacman -S --needed --noconfirm paru
    else
        run sudo pacman -S --needed --noconfirm base-devel git
        local tmp
        tmp=$(mktemp -d)
        run git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
        if ((dry)); then
            echo "+ (cd $tmp/paru-bin && makepkg -si --noconfirm)"
        else
            (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
        fi
        rm -rf "$tmp"
    fi
    if ((!dry)) && ! command -v paru >/dev/null; then
        echo "paru could not be installed" >&2
        exit 1
    fi
}

# has_gpu intel|nvidia, detected from sysfs like hypr/gpu.lua does.
has_gpu() {
    local want id v
    case "$1" in
        intel) want=8086 ;;
        nvidia) want=10de ;;
        *) return 1 ;;
    esac
    for v in /sys/class/drm/card*/device/vendor; do
        [[ -r "$v" ]] || continue
        id=$(<"$v")
        [[ "${id#0x}" == "$want" ]] && return 0
    done
    return 1
}
