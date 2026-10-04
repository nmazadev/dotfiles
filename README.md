# dotfiles

Hyprland (Lua config) + Waybar on Arch, for Intel-only and hybrid Intel/NVIDIA laptops.

## Contents
- `hypr/` Hyprland config, split by concern. `hyprland.lua` requires each file in order:
  - `vars.lua` terminal (`kitty`), file manager (`yazi`), launcher (`wofi --show drun`), main mod (`SUPER`)
  - `monitors.lua` laptop panel (eDP-1 1920x1080@240), an external MSI G27C5 at 144 Hz, and a fallback rule for unknown monitors
  - `env.lua` cursor theme (`rose-pine-hyprcursor`, size 24)
  - `gpu.lua` automatic GPU setup (see [GPU notes](#gpu-notes))
  - `autostart.lua` starts `awww-daemon`, `waybar` and `hypridle`
  - `looks.lua` dwindle layout, gaps, rounded corners, 0.92 window opacity, no borders, blur off, animations
  - `input.lua` `us` + `latam` keyboard layouts, 3-finger horizontal swipe to switch workspaces
  - `binds.lua` keybindings (see [Keybindings](#keybindings))
  - `hypridle.conf` / `hyprlock.conf` lock after 5 min, screen off after 6 min
  - `scripts/wallpaper.sh` picks a wallpaper, recolors the setup with pywal, and restarts waybar; it only reads your images and writes a blurred copy for wlogout
- `waybar/` top bar with workspaces and a taskbar on the left, the clock (with calendar) in the centre, then a hardware group (CPU, temperature, disk, memory), audio, bluetooth, network, battery and an exit button. `launch.sh` restarts it.
- `kitty/` terminal config (JetBrains Mono, 12 pt)
- `wofi/` application launcher config and style
- `wlogout/` logout menu (layout, icons, style)
- `bin/` helper scripts, linked into `~/.local/bin`
  - `prime-run <cmd>` runs a program on the NVIDIA GPU (a plain pass-through if there is none)
- `install.sh` symlinks everything into place

## Dependencies
- Core: `hyprland` `waybar` `kitty` `wofi` `wlogout` `hypridle` `hyprlock` `awww` `yazi`
- Bindings: `grimblast` (screenshots), `brightnessctl`, `playerctl`, `wireplumber` (`wpctl`)
- Wallpaper script: `python-pywal` (`wal`), `imagemagick`; it expects images in `~/wallpapers/`
- Fonts and cursor: JetBrains Mono, `rose-pine-hyprcursor`
- Hybrid laptops only: `nvidia-open` (or `nvidia`) and `nvidia-utils`, optionally `libva-nvidia-driver`

## Install
```sh
./install.sh --dry-run   # preview
./install.sh             # existing configs are moved to *.bak
```
It links `hypr`, `waybar`, `kitty`, `wofi` and `wlogout` into `~/.config`, and each file in `bin/` into `~/.local/bin`. Running it again is safe: links that are already correct are left alone.

## Keybindings
`SUPER` is the main modifier.

| Keys | Action |
| --- | --- |
| `SUPER + Return` | open terminal |
| `SUPER + A` | application launcher |
| `SUPER + Q` / `SUPER + K` | close / kill window |
| `SUPER + F` or `ALT + Return` | fullscreen |
| `SUPER + V` | toggle floating |
| `SUPER + D` / `SUPER + J` | pseudo-tile / toggle split |
| `SUPER + arrows` | move focus |
| `SUPER + SHIFT + arrows` | resize window |
| `SUPER + SHIFT + CTRL + arrows` | move window |
| `SUPER + 1..0` / `+ SHIFT` | go to / send window to workspace 1-10 |
| `SUPER + Tab`, mouse wheel | next workspace (wheel also goes back) |
| `SUPER + CTRL + left/right/down` | previous / next / first empty workspace |
| `SUPER + left mouse` / `+ SHIFT` | drag / resize window |
| `SUPER + W` | new wallpaper and colors |
| `SUPER + B` / `SUPER + SHIFT + B` | toggle / restart waybar |
| `SUPER + M` | logout menu |
| `SUPER + P` | screenshot of the screen |
| `SUPER + SHIFT + P` | screenshot of an area |
| `SUPER + ALT + P` | screenshot after 5 s |
| `SUPER + CTRL + P` | screenshot including the cursor |
| `ALT + SHIFT` | switch keyboard layout (`us` / `latam`) |
| `CTRL + SHIFT + R` | reload the Hyprland config |
| `SUPER + Delete` | exit Hyprland |
| media keys | volume, mic mute, playback, brightness |

Layout switching is handled by XKB (`kb_options = "grp:alt_shift_toggle"` in `hypr/input.lua`), not by a bind, so it works with any keyboard.

## GPU notes
`hypr/gpu.lua` detects the GPUs from `/sys/class/drm` at startup, so nothing needs editing per machine.
- **Intel only:** no overrides; Hyprland's defaults are used.
- **Hybrid Intel + NVIDIA:** the Intel iGPU drives Hyprland (`AQ_DRM_DEVICES`), hardware cursors are disabled, `NVD_BACKEND=direct` is set when `libva-nvidia-driver` is installed, and the NVIDIA GPU stays idle until an app is started with `prime-run <cmd>`.
- NVIDIA-only and AMD setups are not handled.

The hybrid branch is adapted from [meowrch's gpu-env.lua](https://github.com/meowrch/meowrch/blob/main/home/.config/hypr/default/gpu-env.lua), without its global NVIDIA variables so the dGPU is not used for everything.

## Machine-specific parts
- `hypr/monitors.lua` is written for my laptop. On other hardware, edit it for your panel; an unsupported mode makes Hyprland warn and fall back to the preferred one. The old hyprmon-generated `monitors.conf` is not used.
