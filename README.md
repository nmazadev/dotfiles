<div align="center">

# 🌿 nmazadev's dotfiles

*a quiet little corner of Arch, tuned for late nights and warm colors*

![nmazadev](https://img.shields.io/badge/nmazadev-Arch-1793d1?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-Hyprland%20Lua-58e1ff?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-Waybar-a6e3a1?style=flat-square)
![nmazadev](https://img.shields.io/badge/nmazadev-pywal-f9e2af?style=flat-square)

`hyprland` · `waybar` · `kitty` · `wofi` · `wlogout` · `mako` · `pywal`

Made for Intel-only and hybrid Intel + NVIDIA laptops.

</div>

---

## ✨ The vibe

Compact and cozy: a slim 26 px bar, soft rounded corners, slightly see-through windows (0.95), tight 6 px gaps, a slim accent outline on the focused window, no blur, gentle animations.
The default palette is **cocoa** (cream on warm brown, terracotta and amber accents). `SUPER + T` opens a theme menu and `SUPER + SHIFT + T` cycles: `cocoa`, `rose-pine-moon`, `gruvbox`, `nord`, or `pywal`, where the colors follow the wallpaper. Rose Pine cursor, JetBrains Mono everywhere.

## 🚀 Quick start

On a fresh EndeavourOS with no desktop (only `git` is needed; `paru` is installed automatically if missing):

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
| `install-services.sh` | enables NetworkManager, bluetooth, pipewire, power profiles, SSD trim and package-cache cleanup; sets up zram swap; makes zsh the login shell with oh-my-zsh and its plugins; creates `~/wallpapers` |
| `install.sh` | links `~/.zshrc`, the per-user `makepkg.conf`, `hypr`, `waybar`, `kitty`, `wofi`, `wlogout` and `mako` into `~/.config`, the pywal templates into `~/.config/wal/templates` and `bin/` into `~/.local/bin`; existing configs are moved to `*.bak` |
| `install-extras.sh` | optional apps (`tlock`, `xleak-bin`, `tabiew`, `zed`, `spotify`, `onlyoffice-bin`) and the lidm login manager with its theme |

Everything is safe to run again. When it finishes, log in to Hyprland: the repo's wallpaper is already in `~/wallpapers`, and you can drop more images there. At login `hypr/scripts/startup.sh` restores the wallpaper, generates the pywal colors for waybar and kitty and starts waybar (with an empty folder you get a notification instead, and waybar still starts). `SUPER + W` picks a new wallpaper any time.

### Installing over an existing setup (e.g. meowrch)

No wipe needed: `install-over.sh` installs on top of what is there, and `cleanup-meowrch.sh` removes the old desktop afterwards.

```sh
./snapshot.sh before-dotfiles # optional: a snapshot of / and /home right now
./install-over.sh --dry-run   # see what it will do
./install-over.sh             # snapshot, install, snapshot
# reboot, log into Hyprland, check everything works, then:
./cleanup-meowrch.sh --dry-run
./cleanup-meowrch.sh          # lists everything and asks before removing
```

`install-over.sh`:
1. Takes a read-only btrfs snapshot of `/` and `/home` **before** anything changes (`pre-dotfiles-<date>`, your fallback). Snapshots are instant and take no space at first; skipped if `/` isn't btrfs.
2. Sets aside (`*.bak`) what would override this setup: a `~/.zshenv` that redirects zsh to `~/.config/zsh` (meowrch's does, so `~/.zshrc` would be ignored), meowrch's `environment.d` file and its UWSM folder. The old display manager (SDDM) is disabled in favour of lidm, and zsh becomes the login shell (replacing fish).
3. Runs `bootstrap.sh`. Replaced configs are kept as `*.bak`.
4. Takes a second snapshot **after** (`post-dotfiles-<date>`), a milestone of the working setup before the cleanup.

`cleanup-meowrch.sh` removes only meowrch's desktop pieces (bspwm, polybar, rofi, dunst/swaync, SDDM, fish, starship, its theming tools, ...), its helper scripts and user services, and the `*.bak` copies of replaced configs. Apps you may use for work (Firefox, VS Code, Discord, LibreOffice, databases, ...) and app data such as `~/.config/Cursor` and `~/.cursor` are never touched.

`snapshot.sh [label]` works on its own any time (`./snapshot.sh --list` shows them). To get something back, copy it out of a snapshot (`cp -a /home/.snapshots/pre-dotfiles-<date>/$USER/.config/<dir> ~/.config/<dir>.old`). When you're happy, delete the snapshots with `sudo btrfs subvolume delete <path>`.

## 🧺 What's in the basket

| Folder | What lives there |
| --- | --- |
| `hypr/` | Hyprland, written in Lua and split by concern |
| `waybar/` | the top bar, `launch.sh` restarts it |
| `kitty/` | terminal, JetBrains Mono 12 pt |
| `wofi/` | the `SUPER + A` app launcher: config and a theme-aware style |
| `zsh/` | `zshrc`: oh-my-zsh (robbyrussell, autosuggestions, fast-syntax-highlighting), zoxide as `cd`, pywal colors, git aliases, `EDITOR=vim` |
| `pacman/` | per-user `makepkg.conf`: AUR packages build on every CPU thread |
| `micro/` | micro (for notes): settings and a `cozy` colorscheme from the terminal palette, so it follows the theme like vim |
| `vim/` | `vimrc` and the `cozy` colorscheme, which follows the terminal palette so vim matches the theme |
| `fastfetch/` | fastfetch config (OS, host, CPU, both GPUs, RAM, disk, every monitor with refresh rate, battery, uptime, now playing) and logos |
| `wlogout/` | logout menu: layout, icons, style |
| `gtk-3.0/`, `gtk-4.0/` | GTK settings and extra styling for pavucontrol, blueman and other GTK apps |
| `mako/` | notification daemon, colored by pywal |
| `wallpapers/` | the default wallpaper, copied into `~/wallpapers` by `install-services.sh` |
| `wal/` | `colorschemes/` (the fixed palettes) and `templates/` (pywal templates, so far the mako colors) |
| `bin/` | helper scripts, linked into `~/.local/bin` |

<details>
<summary><b>🪟 Inside <code>hypr/</code></b></summary>

`hyprland.lua` requires each file in order:

- `vars.lua` terminal (`kitty`), file manager (`yazi`), launcher (`wofi --show drun`), main mod (`SUPER`)
- `monitors.lua` laptop panel (eDP-1, native resolution at its highest refresh rate), plus a catch-all rule: any other monitor gets its best resolution at the highest refresh rate, placed to the right
- `env.lua` cursor theme (`rose-pine-hyprcursor`, size 24) and `vim` as the default `EDITOR`/`VISUAL`
- `gpu.lua` automatic GPU setup, see [GPU notes](#-gpu-notes)
- `autostart.lua` starts `awww-daemon`, `mako`, `hypridle`, `media-inhibit.sh` and the polkit agent, and runs `startup.sh` (wallpaper, pywal colors, waybar), and handles monitor hotplug
- `looks.lua` dwindle layout, 3/6 px gaps, 12 px rounded corners, 0.95 opacity, a 2 px accent outline on the focused window (faint on the rest), blur off, animations
- `input.lua` `us` + `latam` layouts, 3-finger swipe to change workspace
- `binds.lua` keybindings, see [Keybindings](#-keybindings)
- `hypridle.conf` / `hyprlock.conf` dim at 4.5 min, lock at 5 min, screens off at 6 min, and lock before suspend. Nothing happens while media plays: `scripts/media-inhibit.sh` holds an idle inhibitor whenever an app plays audio (music, video) or records the mic (Discord, meetings)
- `scripts/theme.sh` switches the color theme (see Themes below)
- `scripts/wallpaper.sh` picks a wallpaper, recolors with pywal, restarts waybar and reloads mako. It only reads your images and writes a blurred copy for wlogout
- `scripts/startup.sh` runs at login: restores the wallpaper and theme colors, then starts waybar
- `scripts/gtk-theme.sh` writes the GTK3/GTK4 stylesheets from the current theme
- `scripts/monitor-hotplug.sh` extends (never mirrors) new monitors, re-applies the wallpaper and relaunches waybar

</details>

<details>
<summary><b>📊 Inside <code>waybar/</code></b></summary>

On the left the system tray, folded behind a small arrow (click it to show the icons; right-click an icon for the app's menu, e.g. to quit Discord or Slack), then the workspaces; the clock in the middle (long format with the day and month, click for the short one, hover for the calendar), then a Spotify
now-playing pill (title plus previous / play-pause / next buttons, hidden while Spotify is closed), a hardware group
(CPU, temperature, disk, memory), the keyboard layout (click to switch), audio, bluetooth, network, battery, a do-not-disturb bell (click it or `SUPER + N` to silence notifications), and an exit button.
Clicks open TUIs in kitty: `btop` for the hardware modules, `wiremix` for audio, `bluetui` for bluetooth, `nmtui` for network.

</details>

<details>
<summary><b>🔧 Inside <code>bin/</code></b></summary>

- `prime-run <cmd>` runs a program on the NVIDIA GPU (a plain pass-through if there is none)
- `screenshot [screen|area|window|all]` captures with grim and opens satty

</details>

## 📦 Ingredients

`install-packages.sh` installs all of these:

- **Core:** `hyprland` `waybar` `kitty` `wofi` `wlogout` `mako` `hypridle` `hyprlock` `awww` `yazi`
- **Bindings:** `grim` + `slurp` + `satty` + `wl-clipboard` (screenshots), `brightnessctl`, `playerctl`, `wireplumber` (`wpctl`)
- **System info:** `fastfetch` (config in `fastfetch/`)
- **TUIs (waybar clicks open them in kitty):** `wiremix` (audio), `bluetui`, `nmtui` (comes with NetworkManager), `btop`, plus `glow`, `yazi`, `fastfetch`, `zoxide`, and `envy-tui-bin` + `envycontrol` on hybrid laptops
- **Wallpapers:** `python-pywal` (`wal`) and `imagemagick`. Put your images in `~/wallpapers/`
- **Look:** JetBrains Mono (+ Nerd Font), Noto fonts, `adwaita-icon-theme`, `rose-pine-hyprcursor`
- **System:** pipewire, bluez, NetworkManager, xdg portals, `hyprpolkitagent`, `power-profiles-daemon`, `zram-generator`, `pacman-contrib` (paccache), `gnome-keyring`
- **Shell:** `zsh` with oh-my-zsh, `zsh-autosuggestions` and `fast-syntax-highlighting` (cloned by `install-services.sh`)
- **GPU (detected):** `mesa` `vulkan-intel` `intel-media-driver`, and `nvidia-open` `nvidia-utils` `egl-wayland` `libva-nvidia-driver`
- **Extras (`install-extras.sh`):** `tlock` (2FA tokens TUI), `xleak-bin` (Excel viewer TUI), `tabiew` (CSV viewer TUI), `zed`, `spotify` (shown in waybar through its mpris module), `onlyoffice-bin`, and the login manager `lidm` + `lidm-systemd` from the AUR

## ⌨️ Keybindings

`SUPER` is the main key.

**Everyday**

| Keys | Does |
| --- | --- |
| `SUPER + Return` | terminal |
| `SUPER + A` | app launcher |
| `SUPER + M` | logout menu |
| `SUPER + N` | toggle do not disturb (notifications hidden, still kept) |
| `SUPER + W` | new wallpaper (and new colors with the pywal theme) |
| `SUPER + T` / `SUPER + SHIFT + T` | theme menu / next theme |
| `SUPER + B` / `SUPER + SHIFT + B` | toggle / restart waybar |
| `ALT + SHIFT` | switch layout (`us` / `latam`), shown in waybar |
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

**Screenshots** 📸 (captured with `grim`, then opened in [satty](https://github.com/Satty-org/Satty) to annotate, copy or save)

| Keys | Does |
| --- | --- |
| `Print` (`Fn + F12` on many laptops) | an area (drag to select; it can span several monitors) |
| `SHIFT + Print` | the focused monitor |
| `CTRL + Print` | all monitors in one image |
| `ALT + Print` | the focused window |
| `SUPER + Print` | the focused monitor after 5 s |

In satty, `Enter` copies to the clipboard and `Esc` closes; the save button writes to `~/Images/Screenshots`. The palette follows the theme. The logic lives in `bin/screenshot`, which you can also run directly (`screenshot area --delay 3`, add `--cursor` to include the pointer).

Media keys handle volume, mic mute, playback and brightness.
Layout switching is done by XKB (`grp:alt_shift_toggle` in `hypr/input.lua`), not a bind, so it works with any keyboard.

## 🎨 Themes

Every color on the desktop comes from pywal's cache (`~/.cache/wal`), so a theme is just a palette that pywal applies:
waybar, wofi, wlogout, mako, hyprlock, kitty, cava, the focused-window outline and the GTK apps (pavucontrol, blueman) all follow it.

- Fixed palettes live in `wal/colorschemes/*.json` (`cocoa`, `rose-pine-moon`, `gruvbox`, `nord`), linked by `install.sh`. The `cursor` color is the accent used for the clock, exit button and notification borders.
- `pywal` derives the colors from the current wallpaper instead.
- `hypr/scripts/theme.sh [name|next]` applies one (no argument opens a wofi menu) and remembers it in `~/.cache/wal/theme`; `SUPER + W` keeps the chosen theme and only changes the wallpaper, unless it is `pywal`.
- The wofi launcher is styled by `wofi/style.css`; `gtk-theme.sh` prepends the theme colors into `~/.cache/wal/wofi.css`, which `hypr/vars.lua` passes to wofi.
- vim uses its own `cozy` colorscheme built from the terminal's 16 ANSI colors, so it follows the theme as soon as kitty does (new terminals pick the colors up through pywal's sequences).
- GTK apps are themed by `gtk-3.0/` and `gtk-4.0/`: `hypr/scripts/gtk-theme.sh` writes `~/.config/gtk-*/gtk.css` from the theme colors plus each folder's `extra.css`, and `settings.ini` sets dark mode and the font. Reopen an app to see a theme change.
- To add a palette, copy a file in `wal/colorschemes/`, change the colors and run `./install.sh`.

## 🖥️ Screen sharing

Discord, browsers and OBS share through `xdg-desktop-portal` with the `xdg-desktop-portal-hyprland` backend (installed by `install-packages.sh`). Pick a monitor, window or region in the picker that pops up. `autostart.lua` restarts the portal at login so it always has the Hyprland backend; `hypr/xdph.conf` caps sharing at 60 fps and remembers your choice so apps can reshare without asking. The picker is a Qt app: it floats, centered and solid, and follows the theme through `qt6ct` (palette written by `gtk-theme.sh`, `QT_QPA_PLATFORMTHEME=qt6ct` in `env.lua`), like any other Qt app.

If an app says screen sharing is unavailable, run `systemctl --user restart xdg-desktop-portal` and try again.

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

`hypr/monitors.lua` picks each panel's native resolution at its highest refresh rate, so it works on different laptops as is. Pin a mode there (e.g. `"2560x1600@165"`) only if you want something else; an unsupported mode makes Hyprland warn and fall back to the preferred one.

## 📚 References

**Wallpaper**
- [Photo by elliott on Unsplash](https://unsplash.com/photos/BNMKtpMgkUw) (`wallpapers/elliott-BNMKtpMgkUw-unsplash.jpg`)

**Base and inspiration**
- [meowrch](https://github.com/meowrch/meowrch) and its [gpu-env.lua](https://github.com/meowrch/meowrch/blob/main/home/.config/hypr/default/gpu-env.lua), the base of the hybrid GPU setup
- [Hyprland wiki](https://wiki.hypr.land/), including the NVIDIA and multi-GPU pages
- [Arch Wiki: Hyprland](https://wiki.archlinux.org/title/Hyprland) and [NVIDIA](https://wiki.archlinux.org/title/NVIDIA)

**Desktop**
- [Hyprland](https://github.com/hyprwm/Hyprland), [hypridle](https://github.com/hyprwm/hypridle) and [hyprlock](https://github.com/hyprwm/hyprlock)
- [Waybar](https://github.com/Alexays/Waybar), [mako](https://mako-project.org), [kitty](https://github.com/kovidgoyal/kitty), [wofi](https://hg.sr.ht/~scoopta/wofi) and [wlogout](https://github.com/ArtsyMacaw/wlogout)
- [pywal](https://github.com/dylanaraps/pywal), which drives every theme
- [lidm](https://github.com/javalsai/lidm), the login manager

**Palettes**
- [Rose Pine](https://rosepinetheme.com/), [Gruvbox](https://github.com/morhetz/gruvbox) (the sage variant follows [gruvbox-material](https://github.com/sainnhe/gruvbox-material)) and [Nord](https://www.nordtheme.com/)

**Screenshots**
- [satty](https://github.com/Satty-org/Satty), [grim](https://sr.ht/~emersion/grim/) and [slurp](https://github.com/emersion/slurp)

**Shell**
- [oh-my-zsh](https://ohmyz.sh/), [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)

**Terminal tools**
- [wiremix](https://github.com/tsowell/wiremix) (audio), [bluetui](https://github.com/pythops/bluetui) (bluetooth), `nmtui` from [NetworkManager](https://networkmanager.dev/) (network)
- [btop](https://github.com/aristocratos/btop), [yazi](https://github.com/sxyazi/yazi), [glow](https://github.com/charmbracelet/glow), [fastfetch](https://github.com/fastfetch-cli/fastfetch) and [zoxide](https://github.com/ajeetdsouza/zoxide)
- [Zed](https://zed.dev/) (editor) and [vim](https://www.vim.org/)
- [tlock](https://github.com/eklairs/tlock) (2FA tokens), [xleak](https://github.com/bgreenwell/xleak) (Excel viewer) and [tabiew](https://github.com/shshemi/tabiew) (CSV viewer)

**Apps**
- [pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/) and [blueman](https://github.com/blueman-project/blueman), themed through GTK
- [Spotify](https://www.spotify.com/) and [ONLYOFFICE](https://www.onlyoffice.com/)

---

<div align="center">

*grab a tea, tweak a little, enjoy* 🍵

</div>
