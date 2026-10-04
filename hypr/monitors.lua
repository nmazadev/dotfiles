-- Laptop panel
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@240",
    position = "0x0",
    scale = 1,
})

-- Any other monitor (hotplug): best resolution at the highest refresh rate,
-- placed to the right of the existing ones.
hl.monitor({
    output = "",
    mode = "highrr",
    position = "auto-right",
    scale = 1,
})
