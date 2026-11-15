-- ==== RESIZING STATES ====
return function(cfg, deps)
    local waywall = deps.waywall
    local helpers = deps.helpers
    local tools = deps.tools
    local state = deps.state

    local thin_enable = function()
        state.thin_active = true
        if cfg.sens_change.enabled then
            tools.set_sens(cfg.sens_change.normal)
        end
    end
    local tall_enable = function()
        if cfg.sens_change.enabled and not state.thin_active then
            tools.set_sens(cfg.sens_change.tall)
        end
        state.thin_active = false
    end
    local wide_enable = function()
        if cfg.sens_change.enabled then
            tools.set_sens(cfg.sens_change.normal)
        end
        state.thin_active = false
    end
    local res_disable = function()
        if cfg.sens_change.enabled then
            tools.set_sens(cfg.sens_change.normal)
        end
        state.thin_active = false
    end

    -- ==== RESOLUTIONS ====
    local make_res = function(width, height, enable, disable)
        return function()
            local active_width, active_height = waywall.active_res()

            if active_width == width and active_height == height then
                if cfg.enable_resize_animations then
                    os.execute('echo "0x0" > ~/.resetti_state')
                    waywall.sleep(17)
                end
                waywall.set_resolution(0, 0)
                disable()
            else
                if cfg.enable_resize_animations then
                    os.execute(string.format('echo "%dx%d" > ~/.resetti_state', width, height))
                    waywall.sleep(17)
                end
                waywall.set_resolution(width, height)
                enable()
            end
        end
    end

    local resolutions = {
        thin = make_res(cfg.thin_res[1], cfg.thin_res[2], thin_enable, res_disable),
        tall = make_res(cfg.tall_res[1], cfg.tall_res[2], tall_enable, res_disable),
        wide = make_res(cfg.wide_res[1], cfg.wide_res[2], wide_enable, res_disable),
    }

    local function chat_mode_helper(body)
        return function()
            if not state.remaps_active then
                return false
            end
            return body()
        end
    end

    local function resize_helper(mode, run, ingame_only)
        local resize = function()
            if mode.f3_safe and waywall.get_key("F3") then
                return false
            end
            return run()
        end

        if ingame_only then
            return helpers.ingame_only(resize)
        end

        return resize
    end

    return {
        resolutions = resolutions,
        chat_mode_helper = chat_mode_helper,
        resize_helper = resize_helper,
    }
end
