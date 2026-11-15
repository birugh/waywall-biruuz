-- ==== KEYBOARD ====
return {
    xkb_config = {
        enabled = false,
        layout = "mc", -- ~/.config/xkb/symbols/mc
        rules = nil,   -- ~/.config/xkb/rules/...
        variant = "basic",
        options = "caps:none",
    },
    remaps_text_config = { text = "Remaps off", x = 50, y = 1020, size = 2, color = "#000000" },
}
