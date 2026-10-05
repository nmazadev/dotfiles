hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "24")

-- vim is the default editor (git, sudoedit, yazi, ...); micro is installed for notes
hl.env("EDITOR", "vim")
hl.env("VISUAL", "vim")

-- Qt apps (screen share picker, ...) use the qt6ct palette written by gtk-theme.sh
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Run apps natively on Wayland when they can (sharper text, screen sharing):
-- older Electron apps follow this hint (current ones pick Wayland already), and Qt
-- apps use Wayland with X11 as the fallback for those that can't
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
