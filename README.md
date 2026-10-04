# dotfiles

Hyprland (Lua config) + Waybar on Arch, for a hybrid Intel/NVIDIA laptop.

## Contents
- `hypr/` Hyprland config, split by concern. `hyprland.lua` requires each file; `gpu.lua` holds the hybrid GPU setup.
- `waybar/`, `kitty/`, `wofi/`, `wlogout/`
- `bin/` helper scripts, linked into `~/.local/bin` (`prime-run` runs an app on the NVIDIA GPU)

## Dependencies
`hyprland` `waybar` `kitty` `wofi` `wlogout` `hypridle` `hyprlock` `awww` `yazi`, `nvidia-open` `nvidia-utils`, optionally `libva-nvidia-driver`.

## Install
```sh
./install.sh --dry-run   # preview
./install.sh             # existing configs are moved to *.bak
```

## GPU notes
The Intel iGPU drives Hyprland (`AQ_DRM_DEVICES`). The NVIDIA GPU is off until an app is started with `prime-run <cmd>`. The PCI addresses in `hypr/gpu.lua` (`00:02.0`, `01:00.0`) are specific to this laptop; check `lspci` on other hardware.

## Hyprland monitors
`hypr/monitors.lua` is hand-written. The old hyprmon-generated `monitors.conf` is not used.
# dotfiles
