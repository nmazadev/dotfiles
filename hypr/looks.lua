-- Theme colors written by pywal (wal/templates/colors-hypr.lua), refreshed by theme.sh
local ok, colors = pcall(dofile, (os.getenv("HOME") or "") .. "/.cache/wal/colors-hypr.lua")
if not ok then colors = { accent = "c4785a", muted = "a08c7d" } end

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,
        -- Slim accent outline on the focused window, barely-there on the rest
        border_size = 2,
        col = {
            active_border = "rgba(" .. colors.accent .. "e6)",
            inactive_border = "rgba(" .. colors.muted .. "33)",
        },
        layout = "dwindle",
        -- drag any window's border (or the gap next to it) to resize it, not only
        -- apps that draw their own resize edges
        resize_on_border = true,
        extend_border_grab_area = 12,
        hover_icon_on_border = true,
        allow_tearing = false,
    },

    decoration = {
        rounding = 12,
        active_opacity = 0.95,
        inactive_opacity = 0.95,
        fullscreen_opacity = 1,
        blur = {
            enabled = false,
            size = 3,
            passes = 1,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- satty (screenshot annotation) opens as a floating window instead of tiling
hl.window_rule({
    name = "satty-float",
    match = { class = "com.gabm.satty" },
    float = true,
    size = "1100 700",
    center = true,
})

-- screen share picker (xdg-desktop-portal-hyprland): a centered, solid dialog
hl.window_rule({
    name = "share-picker",
    match = { class = "hyprland-share-picker" },
    float = true,
    center = true,
    opacity = "1.0 override 1.0 override",
})

-- Firefox fully opaque: videos and pages look wrong with the window translucency
hl.window_rule({
    name = "firefox-opaque",
    match = { class = "^(firefox)$" },
    opacity = "1.0 override 1.0 override",
})
