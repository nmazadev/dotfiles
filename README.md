<div align="center">

# 🌿 nmazadev's dotfiles

*a quiet little corner of Arch, tuned for late nights and warm colors*

![nmazadev](https://img.shields.io/badge/nmazadev-Arch-1793d1?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-Hyprland%20Lua-58e1ff?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-Waybar-a6e3a1?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-pywal-f9e2af?style=flat-square)

`hyprland` · `waybar` · `kitty` · `wofi` · `wlogout` · `pywal`

Made for Intel-only and hybrid Intel + NVIDIA laptops.

</div>

---

## ✨ The vibe

Soft rounded corners, slightly see-through windows (0.92), no borders, no blur, gentle animations.
Press `SUPER + W` and a new wallpaper arrives, and pywal repaints the bar, the terminal and the
launcher to match. Rose Pine cursor, JetBrains Mono everywhere.

## 🚀 Quick start

On a fresh EndeavourOS with no desktop (needs `git` and `paru`):

```sh
git clone git@github.com:nmazadev/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

./bootstrap.sh --dry-run   # peek first
./bootstrap.sh
```

`bootstrap.sh` runs these in order, and each one also works on its own (all take `--dry-run`):

| Script | Does |
| --- | --- |
| `install-packages.sh` | every package the setup needs, plus Intel and NVIDIA drivers when those GPUs are detected |
| `install-services.sh` | enables NetworkManager, bluetooth, pipewire and the polkit agent, creates `~/wallpapers` |
| `install.sh` | links `hypr`, `waybar`, `kitty`, `wofi` and `wlogout` into `~/.config` and `bin/` into `~/.local/bin`; existing configs are moved to `*.bak` |
| `install-extras.sh` | the lidm login manager and its theme |

Everything is safe to run again. When it finishes, drop at least one image in `~/wallpapers` and log in to Hyprland. At login `hypr/scripts/startup.sh` restores the wallpaper, generates the pywal colors for waybar and kitty and starts waybar (with an empty folder you get a notification instead, and waybar still starts). `SUPER + W` picks a new wallpaper any time.

## 🧺 What's in the basket

| Folder | What lives there |
| --- | --- |
| `hypr/` | Hyprland, written in Lua and split by concern |
| `waybar/` | the top bar, `launch.sh` restarts it |
| `kitty/` | terminal, JetBrains Mono 12 pt |
| `wofi/` | app launcher config and style |
| `wlogout/` | logout menu: layout, icons, style |
| `bin/` | helper scripts, linked into `~/.local/bin` |

<details>
<summary><b>🪟 Inside <code>hypr/</code></b></summary>

`hyprland.lua` requires each file in order:

- `vars.lua` terminal (`kitty`), file manager (`yazi`), launcher (`wofi --show drun`), main mod (`SUPER`)
- `monitors.lua` laptop panel (eDP-1 1920x1080@240), plus a catch-all rule: any other monitor gets its best resolution at the highest refresh rate, placed to the right
- `env.lua` cursor theme (`rose-pine-hyprcursor`, size 24)
- `gpu.lua` automatic GPU setup, see [GPU notes](#-gpu-notes)
- `autostart.lua` starts `awww-daemon`, `waybar` and `hypridle`, and handles monitor hotplug
- `looks.lua` dwindle layout, gaps, rounded corners, 0.92 opacity, no borders, blur off, animations
- `input.lua` `us` + `latam` layouts, 3-finger swipe to change workspace
- `binds.lua` keybindings, see [Keybindings](#-keybindings)
- `hypridle.conf` / `hyprlock.conf` lock after 5 min, screen off after 6 min
- `scripts/wallpaper.sh` picks a wallpaper, recolors with pywal and restarts waybar. It only reads your images and writes a blurred copy for wlogout
- `scripts/monitor-hotplug.sh` extends (never mirrors) new monitors, re-applies the wallpaper and relaunches waybar

</details>

<details>
<summary><b>📊 Inside <code>waybar/</code></b></summary>

Workspaces and a taskbar on the left, the clock (with calendar) in the middle, then a hardware group
(CPU, temperature, disk, memory), audio, bluetooth, network, battery and an exit button.

</details>

<details>
<summary><b>🔧 Inside <code>bin/</code></b></summary>

- `prime-run <cmd>` runs a program on the NVIDIA GPU (a plain pass-through if there is none)

</details>

## 📦 Ingredients

`install-packages.sh` installs all of these:

- **Core:** `hyprland` `waybar` `kitty` `wofi` `wlogout` `hypridle` `hyprlock` `awww` `yazi`
- **Bindings:** `grimblast-git` (screenshots), `brightnessctl`, `playerctl`, `wireplumber` (`wpctl`)
- **TUIs (waybar clicks open them in kitty):** `bluetui`, `nmtui` (comes with NetworkManager), `btop`, plus `glow`, `yazi`, `fastfetch`, `zoxide`, and `envy-tui-bin` + `envycontrol` on hybrid laptops
- **Wallpapers:** `python-pywal` (`wal`) and `imagemagick`. Put your images in `~/wallpapers/`
- **Look:** JetBrains Mono (+ Nerd Font), Noto fonts, `adwaita-icon-theme`, `rose-pine-hyprcursor`
- **System:** pipewire, bluez, NetworkManager, xdg portals, `hyprpolkitagent`
- **GPU (detected):** `mesa` `vulkan-intel` `intel-media-driver`, and `nvidia-open` `nvidia-utils` `egl-wayland` `libva-nvidia-driver`
- **Login manager:** `lidm` and `lidm-systemd` from the AUR

## ⌨️ Keybindings

`SUPER` is the main key.

**Everyday**

| Keys | Does |
| --- | --- |
| `SUPER + Return` | terminal |
| `SUPER + A` | app launcher |
| `SUPER + M` | logout menu |
| `SUPER + W` | new wallpaper and colors |
| `SUPER + B` / `SUPER + SHIFT + B` | toggle / restart waybar |
| `ALT + SHIFT` | switch layout (`us` / `latam`) |
| `CTRL + SHIFT + R` | reload Hyprland config |
| `SUPER + Delete` | exit Hyprland |

**Windows**

| Keys | Does |
| --- | --- |
| `SUPER + Q` / `SUPER + K` | close / kill |
| `SUPER + F` or `ALT + Return` | fullscreen |
| `SUPER + V` | toggle floating |
| `SUPER + D` / `SUPER + J` | pseudo-tile / toggle split |
| `SUPER + arrows` | move focus |
| `SUPER + SHIFT + arrows` | resize |
| `SUPER + SHIFT + CTRL + arrows` | move window |
| `SUPER + left mouse` / `+ SHIFT` | drag / resize |

**Workspaces**

| Keys | Does |
| --- | --- |
| `SUPER + 1..0` / `+ SHIFT` | go to / send window to workspace 1-10 |
| `SUPER + Tab`, mouse wheel | next workspace (wheel also goes back) |
| `SUPER + CTRL + left/right/down` | previous / next / first empty |

**Screenshots** 📸

| Keys | Does |
| --- | --- |
| `SUPER + P` | whole screen |
| `SUPER + SHIFT + P` | an area |
| `SUPER + ALT + P` | after 5 s |
| `SUPER + CTRL + P` | including the cursor |

Media keys handle volume, mic mute, playback and brightness.
Layout switching is done by XKB (`grp:alt_shift_toggle` in `hypr/input.lua`), not a bind, so it works with any keyboard.

## 🎮 GPU notes

`hypr/gpu.lua` detects GPUs from `/sys/class/drm` at startup, so nothing needs editing per machine.

- **Intel only:** no overrides, Hyprland's defaults are used.
- **Hybrid Intel + NVIDIA:** Aquamarine picks the primary GPU on its own (no `AQ_DRM_DEVICES`), GL and Vulkan default to NVIDIA (`__GLX_VENDOR_LIBRARY_NAME`, `VK_LAYER_NV_optimus`), hardware cursors are off, and `NVD_BACKEND=direct` is set when `libva-nvidia-driver` is installed.
- NVIDIA-only and AMD setups are not handled.

The hybrid branch follows [meowrch's gpu-env.lua](https://github.com/meowrch/meowrch/blob/main/home/.config/hypr/default/gpu-env.lua).

## 🔐 Login manager

`./install-extras.sh` installs [lidm](https://github.com/javalsai/lidm) with `paru`, disables `getty@tty1` and enables the lidm service. It takes effect on the next boot, and lidm lists the `Hyprland` session from `/usr/share/wayland-sessions/`.

<details>
<summary>Roll back</summary>

Switch to another tty (`Ctrl+Alt+F3`), log in and run:

```sh
sudo systemctl disable lidm && sudo systemctl enable getty@tty1
```

</details>

## 🧸 Machine-specific bits

`hypr/monitors.lua` is written for my laptop. On other hardware, edit it for your panel; an unsupported mode makes Hyprland warn and fall back to the preferred one.

## 📚 References

- [meowrch](https://github.com/meowrch/meowrch) and its [gpu-env.lua](https://github.com/meowrch/meowrch/blob/main/home/.config/hypr/default/gpu-env.lua), the base of the hybrid GPU setup
- [Hyprland wiki](https://wiki.hypr.land/), including the NVIDIA and multi-GPU pages
- [Hyprland](https://github.com/hyprwm/Hyprland), [hypridle](https://github.com/hyprwm/hypridle) and [hyprlock](https://github.com/hyprwm/hyprlock)
- [Waybar](https://github.com/Alexays/Waybar)
- [pywal](https://github.com/dylanaraps/pywal)
- [lidm](https://github.com/javalsai/lidm)
- [Arch Wiki: Hyprland](https://wiki.archlinux.org/title/Hyprland) and [NVIDIA](https://wiki.archlinux.org/title/NVIDIA)

---

<div align="center">

*grab a tea, tweak a little, enjoy* 🍵

</div>
