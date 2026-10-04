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

require_paru() {
    if ! command -v paru >/dev/null; then
        echo "paru is required but not installed" >&2
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
