-- ==== WAYWALL GENERIC CONFIG ====
local main = require("main")

local remaps = require("remaps")

local cfg = {
    debug_text = false,

    -- ==== LOOKS ====
    resolution = { 1920, 1080 },

    bg_col = "#010101",
    toggle_bg_picture = true,
    text_col = "#FFFFFF",
    pie_chart_1 = "#EC6E4E",
    pie_chart_2 = "#46CE66",
    pie_chart_3 = "#E446C4",

    ninbot_anchor = {
        position = "left", -- topleft, top, topright, left, right, bottomleft, bottomright
        x = 30,
        y = 370,
    },
    ninbot_opacity = 1,        -- 0 to 1


    -- ==== ALTERNATIVE RESOLUTIONS ====
    thin_res = { 340, 1080 },
    wide_res = { 1920, 300 },
    tall_res = { 384, 16384 },


    -- ==== MIRRORS ====
    e_count = { enabled = true, colorkey = false, show_c = true,
        thin = { x = 1190, y = 460, size = 6 },
        tall = { x = 1190, y = 260, size = 6 },
    },

    thin_pie = { enabled = true, x = 746, y = 650, size = 4, colorkey = false },
    tall_pie = { enabled = true, x = 1190, y = 400, size = 4, colorkey = false },

    thin_percent = { enabled = true, x = 850, y = 680, size = 6, colorkey = false },
    tall_percent = { enabled = true, x = 1190, y = 700, size = 6, colorkey = false },
    percentages_match_text = false,

    measuring_window = { x = 30, y = 340, size = 10 },
    stretched_measure = false,

    use_shaders = false,


    -- ==== MACROS ====
    -- resolution changes
    thin = { key = "*-Alt_L", f3_safe = false, ingame_only = true },
    wide = { key = "*-B", f3_safe = true, ingame_only = true },
    tall = { key = "*-F5", f3_safe = false, ingame_only = false },

    -- startup actions
    toggle_fullscreen_key = "Shift-O",
    launch_paceman_key = "Shift-P",

    -- during game actions
    toggle_ninbot_key = "F6", 
    toggle_remaps_key = "Shift-Delete",


    -- ==== KEYBOARD ====
    xkb_config = {
        enabled = false,
        layout = "mc", -- ~/.config/xkb/symbols/mc
        rules = nil,   -- ~/.config/xkb/rules/...
        variant = "basic",
        options = "caps:none",
    },
    remaps_text_config = { text = "Remaps off", x = 50, y = 1020, size = 2, color = "#000000" },


    -- ==== MISC ====
    sens_change = { enabled = true, normal = 3.0542382543041806, tall = 0.2060370856485424 },
    enable_resize_animations = false,

}

return main(cfg, remaps)
