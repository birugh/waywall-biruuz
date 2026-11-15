-- ==== KEYBINDS ====
return function(cfg, deps)
    local waywall = deps.waywall
    local helpers = deps.helpers
    local tools = deps.tools
    local state = deps.state
    local remaps = deps.remaps
    local resolutions = deps.resolutions
    local paths = deps.paths

    local config = deps.config
    config.actions = {

        [cfg.thin.key] = resolutions.resize_helper(cfg.thin, resolutions.resolutions.thin, cfg.thin.ingame_only),
        [cfg.wide.key] = resolutions.resize_helper(cfg.wide, resolutions.resolutions.wide, cfg.wide.ingame_only),
        [cfg.tall.key] = resolutions.resize_helper(cfg.tall, resolutions.resolutions.tall, cfg.tall.ingame_only),

        [cfg.toggle_fullscreen_key] = resolutions.chat_mode_helper(waywall.toggle_fullscreen),

        [cfg.launch_paceman_key] = resolutions.chat_mode_helper(function()
            if state.paceman_text then return end
            if tools.is_pacem_running() then
                print("Paceman Already Running")
                state.paceman_text = waywall.text("Paceman Already Running",
                    { x = 10, y = cfg.resolution[2] - 50, color = "#FFFFFF", size = 3 })
                waywall.sleep(1500)
                state.paceman_text:close()
                state.paceman_text = nil
            else
                waywall.exec("java -jar " .. paths.pacem .. " --nogui")
                print("Paceman Running")
                state.paceman_text = waywall.text("Paceman Running",
                    { x = 10, y = cfg.resolution[2] - 50, color = "#FFFFFF", size = 3 })
                waywall.sleep(1500)
                state.paceman_text:close()
                state.paceman_text = nil
            end
        end),

        [cfg.toggle_ninbot_key] = resolutions.chat_mode_helper(function()
            if not tools.is_ninb_running() then
                waywall.exec("java -Dawt.useSystemAAFontSettings=on -jar " .. paths.nb)
                waywall.show_floating(true)
            else
                helpers.toggle_floating()
            end
        end),

        [cfg.toggle_remaps_key] = function()
            if state.rebind_text then
                state.rebind_text:close()
                state.rebind_text = nil
            end
            if state.remaps_active then
                state.remaps_active = false
                waywall.set_remaps({})

                if cfg.xkb_config.enabled then
                    waywall.set_keymap({
                        layout = nil,
                        rules = nil,
                        variant = nil,
                        options = nil,
                    })
                end

                state.rebind_text = waywall.text(cfg.remaps_text_config.text,
                    {
                        x = cfg.remaps_text_config.x,
                        y = cfg.remaps_text_config.y,
                        color = cfg.remaps_text_config.color,
                        size = cfg.remaps_text_config.size
                    })
            else
                state.remaps_active = true
                waywall.set_remaps(remaps)

                if cfg.xkb_config.enabled then
                    waywall.set_keymap({
                        layout = cfg.xkb_config.layout,
                        rules = cfg.xkb_config.rules,
                        variant = cfg.xkb_config.variant,
                        options = cfg.xkb_config.options
                    })
                end
            end
        end,

        ["Shift-I"] = resolutions.chat_mode_helper(function()
            if state.keybinds_text then
                state.keybinds_text:close()
                state.keybinds_text = nil
                return false
            end
            state.keybinds_text = waywall.text(
                "KEYBINDS:\n" ..
                "Thin = " .. cfg.thin.key .. "\n" ..
                "Wide = " .. cfg.wide.key .. "\n" ..
                "Tall = " .. cfg.tall.key .. "\n" ..
                "Toggle Ninbot = " .. cfg.toggle_ninbot_key .. "\n" ..
                "Launch paceman = " .. cfg.launch_paceman_key .. "\n" ..
                "Fullscreen = " .. cfg.toggle_fullscreen_key .. "\n" ..
                "Chat Mode = " .. cfg.toggle_remaps_key .. "\n"
                ,
                { x = 10, y = 10, color = "#FFFFFF", size = 3 })
            if state.debug_text1 and state.debug_text2 and state.debug_text3 and state.debug_text4 then
                state.debug_text1:close()
                state.debug_text1 = nil
                state.debug_text2:close()
                state.debug_text2 = nil
                state.debug_text3:close()
                state.debug_text3 = nil
                state.debug_text4:close()
                state.debug_text4 = nil
            end
        end),

    }

    return config
end
