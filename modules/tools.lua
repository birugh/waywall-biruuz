-- ==== TOOLS ====
return function(cfg, deps)
    local waywall = deps.waywall
    local config_dir = deps.paths.config_dir

    local is_ninb_running = function()
        local handle = io.popen("ps aux | grep '[N]injabrain-Bot.*\\.jar'")
        local result = handle:read("*l")
        handle:close()
        return result ~= nil
    end
    local is_pacem_running = function()
        local handle = io.popen("ps aux | grep '[p]aceman-tracker.*\\.jar'")
        local result = handle:read("*l")
        handle:close()
        return result ~= nil
    end
    local set_sens = function(sens)
        waywall.set_sensitivity(sens)
        waywall.set_raw_sensitivity(sens)
    end
    local read_file = function(name)
        local file = io.open(config_dir .. name, "r")
        if file then
            local data = file:read("*a")
            file:close()
            return data
        else
            print("Error: File \"" .. name .. "\" not found.")
            return
        end
    end
    local hex_to_vec = function(var, hex)
        hex = hex:match("^%s*(.-)%s*$")
        hex = hex:gsub("^#", "")
        hex = hex:lower()

        local hex_segs = {}
        for pair in hex:gmatch("%x%x") do
            table.insert(hex_segs, pair)
        end
        if #hex_segs == 3 then
            table.insert(hex_segs, "ff")
        end

        local r = tonumber(hex_segs[1], 16) / 255
        local g = tonumber(hex_segs[2], 16) / 255
        local b = tonumber(hex_segs[3], 16) / 255
        local a = tonumber(hex_segs[4], 16) / 255

        return "const vec4 " .. var .. " = vec4(" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. ");"
    end

    local compile_colors = function(colors)
        local output = "precision highp float;\n\n"

        for name, hex in pairs(colors) do
            output = output .. hex_to_vec(name, hex) .. "\n\n"
        end

        return output
    end

    return {
        is_ninb_running = is_ninb_running,
        is_pacem_running = is_pacem_running,
        set_sens = set_sens,
        read_file = read_file,
        hex_to_vec = hex_to_vec,
        compile_colors = compile_colors,
    }
end
