local home = os.getenv("HOME") or ""

return {
    terminal = "kitty",
    fileManager = "yazi",
    menu = "wofi --show drun --style " .. home .. "/.cache/wal/wofi.css",
    mainMod = "SUPER",
}
