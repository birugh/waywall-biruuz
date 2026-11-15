-- ==== WAYWALL ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")

-- ==== RESOURCES ====
local waywall_config_path = os.getenv("HOME") .. "/.config/waywall/"
local paths = {
    config_dir = waywall_config_path,
    bg = waywall_config_path .. "resources/background.png",
    tall_overlay = waywall_config_path .. "resources/overlay_tall.png",
    thin_overlay = waywall_config_path .. "resources/overlay_thin.png",
    wide_overlay = waywall_config_path .. "resources/overlay_wide.png",
    pacem = waywall_config_path .. "resources/paceman-tracker-0.7.2.jar",
    nb = waywall_config_path .. "resources/Ninjabrain-Bot-1.5.2.jar",
    overlay = waywall_config_path .. "resources/measuring_overlay.png",
    stretched_overlay = waywall_config_path .. "resources/stretched_overlay.png",
}

-- ==== INITS ====
local debug_text = "Press Shift + I to show keybinds.\n\n" ..
    "Look at the Github's README for a guide to config.\n\n" ..
    "disable this message by setting\n" ..
    "\'debug_text\' to false in ~/.config/waywall/init.lua\n"

-- ==== CONFIG TABLE ====

return function(cfg, remaps)
    -- shared state: hidup hanya di orkestrator, di-inject via deps
    local state = {
        remaps_active = true,
        thin_active = false,
        rebind_text = nil,
        paceman_text = nil,
        keybinds_text = nil,
        debug_text1 = nil,
        debug_text2 = nil,
        debug_text3 = nil,
        debug_text4 = nil,
    }

    local config = {
        input = {
            layout = (cfg.xkb_config.enabled and cfg.xkb_config.layout) or nil,
            rules = (cfg.xkb_config.enabled and cfg.xkb_config.rules) or nil,
            variant = (cfg.xkb_config.enabled and cfg.xkb_config.variant) or nil,
            options = (cfg.xkb_config.enabled and cfg.xkb_config.options) or nil,

            repeat_rate = 40,
            repeat_delay = 300,
            remaps = remaps,
            sensitivity = (cfg.sens_change.enabled and cfg.sens_change.normal) or 1.0,
            confine_pointer = false,
        },
        theme = {
            background = cfg.bg_col,
            background_png = cfg.toggle_bg_picture and paths.bg or nil,
            ninb_anchor = cfg.ninbot_anchor,
            ninb_opacity = cfg.ninbot_opacity,
        },
        experimental = {
            debug = false,
            jit = false,
            tearing = false,
        },
        window = {
            fullscreen_width = cfg.resolution[1],
            fullscreen_height = cfg.resolution[2],
        }
    }

    local deps = {
        waywall = waywall,
        helpers = helpers,
        cfg = cfg,
        remaps = remaps,
        paths = paths,
        state = state,
        config = config,
    }

    -- ==== MODULES ====
    deps.tools = require("modules.tools")(cfg, deps)
    deps.mirrors = require("modules.mirrors")(cfg, deps)
    deps.resolutions = require("modules.resolutions")(cfg, deps)
    config = require("modules.actions")(cfg, deps)

    -- ==== DEBUG TEXT ====
    waywall.listen("load", function()
        if cfg.debug_text then
            state.debug_text1 = waywall.text(debug_text,
                { x = 10, y = 10, color = "#FFFF00", size = 3 })
            state.debug_text2 = waywall.text(debug_text,
                { x = 11, y = 11, color = "#FFFF00", size = 3 })
            state.debug_text3 = waywall.text(debug_text,
                { x = 13, y = 13, color = "#000000", size = 3 })
            state.debug_text4 = waywall.text(debug_text,
                { x = 14, y = 14, color = "#000000", size = 3 })
        end
    end)

    require("extras")(config)

    return config
end
