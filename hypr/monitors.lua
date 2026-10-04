-- Laptop panel: native resolution at its highest refresh rate, so the same rule
-- fits different panels (1080p@240 here, maybe 1600p on a newer model)
hl.monitor({
    output = "eDP-1",
    mode = "highrr",
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
