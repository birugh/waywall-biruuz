-- ==== MIRRORS ====
return function(cfg, deps)
    local helpers = deps.helpers
    local tools = deps.tools
    local paths = deps.paths

    -- ==== MIRRORS ====
    -- colors
    if cfg.use_shaders then
        local shader_colors = {
            text_color = cfg.text_col,
            pie1_color = cfg.pie_chart_1,
            pie2_color = cfg.pie_chart_2,
            pie3_color = cfg.pie_chart_3,
        }

        local compiled_colors = tools.compile_colors(shader_colors)
        local general_vertex = tools.read_file("shaders/general.vert")

        deps.config.shaders = {
            ["text"] = {
                vertex   = general_vertex,
                fragment = compiled_colors .. tools.read_file("shaders/text.frag"),
            },
            ["pie_chart"] = {
                vertex   = general_vertex,
                fragment = compiled_colors .. tools.read_file("shaders/pie_chart.frag"),
            },
            ["percentages"] = {
                vertex   = general_vertex,
                fragment = compiled_colors .. tools.read_file("shaders/percentages.frag"),
            },
        }
    end
    local pie_colors = {
        { input = "#EC6E4E", output = cfg.pie_chart_1 },
        { input = "#46CE66", output = cfg.pie_chart_2 },
        { input = "#CC6C46", output = cfg.pie_chart_2 },
        { input = "#464C46", output = cfg.pie_chart_2 },
        { input = "#E446C4", output = cfg.pie_chart_3 }
    }
    local percentage_colors = {
        { input = "#E96D4D", output = cfg.percentages_match_text and cfg.text_col or cfg.pie_chart_1 },
        { input = "#45CB65", output = cfg.percentages_match_text and cfg.text_col or cfg.pie_chart_2 },
    }

    if cfg.e_count.enabled then
        local function e_mirror(ec, res)
            helpers.res_mirror(
                {
                    src = ec.show_c
                        and { x = 1, y = 28, w = 49, h = 18 }
                        or { x = 13, y = 37, w = 37, h = 9 },
                    dst = ec.show_c
                        and { x = ec.x, y = ec.y, w = 49 * ec.size, h = 18 * ec.size }
                        or { x = ec.x, y = ec.y, w = 37 * ec.size, h = 9 * ec.size },
                    depth = 2,
                    color_key = (ec.colorkey and not cfg.use_shaders) and {
                        input = "#DDDDDD",
                        output = cfg.text_col,
                    } or nil,
                    shader = (ec.colorkey and cfg.use_shaders) and "text" or nil,
                },
                res[1], res[2]
            )
        end
        e_mirror({ show_c = cfg.e_count.show_c, colorkey = cfg.e_count.colorkey,
                   x = cfg.e_count.thin.x, y = cfg.e_count.thin.y, size = cfg.e_count.thin.size },
                 cfg.thin_res)
        e_mirror({ show_c = cfg.e_count.show_c, colorkey = cfg.e_count.colorkey,
                   x = cfg.e_count.tall.x, y = cfg.e_count.tall.y, size = cfg.e_count.tall.size },
                 cfg.tall_res)
    end

    -- thin mirrors
    if cfg.thin_pie.enabled then
        if cfg.thin_pie.colorkey then
            if cfg.use_shaders then
                helpers.res_mirror(
                    {
                        src = { x = cfg.thin_res[1] - 340, y = cfg.thin_res[2] - 406, w = 340, h = 178 },
                        dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
                        depth = 2,
                        shader = "pie_chart",
                    },
                    cfg.thin_res[1], cfg.thin_res[2]
                )
            else
                for _, ck in ipairs(pie_colors) do
                    helpers.res_mirror(
                        {
                            src = { x = cfg.thin_res[1] - 340, y = cfg.thin_res[2] - 406, w = 340, h = 178 },
                            dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 423 * cfg.thin_pie.size / 4 },
                            depth = 2,
                            color_key = ck,
                        },
                        cfg.thin_res[1], cfg.thin_res[2]
                    )
                end
            end
        else
            helpers.res_mirror(
                {
                    src = { x = cfg.thin_res[1] - 340, y = cfg.thin_res[2] - 406, w = 340, h = 221 },
                    dst = { x = cfg.thin_pie.x, y = cfg.thin_pie.y, w = 420 * cfg.thin_pie.size / 4, h = 273 * cfg.thin_pie.size / 4 },
                    depth = 2,
                },
                cfg.thin_res[1], cfg.thin_res[2]
            )
        end
    end

    if cfg.thin_percent.enabled then
        if cfg.thin_percent.colorkey then
            if cfg.use_shaders then
                helpers.res_mirror(
                    {
                        src = { x = cfg.thin_res[1] - 93, y = cfg.thin_res[2] - 221, w = 33, h = 25 },
                        dst = { x = cfg.thin_percent.x, y = cfg.thin_percent.y, w = 33 * cfg.thin_percent.size, h = 25 * cfg.thin_percent.size },
                        depth = 3,
                        shader = cfg.percentages_match_text and "text" or "percentages",
                    },
                    cfg.thin_res[1], cfg.thin_res[2]
                )
            else
                for _, ck in ipairs(percentage_colors) do
                    helpers.res_mirror(
                        {
                            src = { x = cfg.thin_res[1] - 93, y = cfg.thin_res[2] - 221, w = 33, h = 25 },
                            dst = { x = cfg.thin_percent.x, y = cfg.thin_percent.y, w = 33 * cfg.thin_percent.size, h = 25 * cfg.thin_percent.size },
                            depth = 3,
                            color_key = ck,
                        },
                        cfg.thin_res[1], cfg.thin_res[2]
                    )
                end
            end
        else
            helpers.res_mirror(
                {
                    src = { x = cfg.thin_res[1] - 93, y = cfg.thin_res[2] - 221, w = 33, h = 25 },
                    dst = { x = cfg.thin_percent.x, y = cfg.thin_percent.y, w = 33 * cfg.thin_percent.size, h = 25 * cfg.thin_percent.size },
                    depth = 3,
                },
                cfg.thin_res[1], cfg.thin_res[2]
            )
        end
    end

    -- tall mirrors
    if cfg.tall_pie.enabled then
        if cfg.tall_pie.colorkey then
            if cfg.use_shaders then
                helpers.res_mirror(
                    {
                        src = { x = 44, y = 15978, w = 340, h = 178 },
                        dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
                        depth = 2,
                        shader = "pie_chart",
                    },
                    cfg.tall_res[1], cfg.tall_res[2]
                )
            else
                for _, ck in ipairs(pie_colors) do
                    helpers.res_mirror(
                        {
                            src = { x = 44, y = 15978, w = 340, h = 178 },
                            dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 423 * cfg.tall_pie.size / 4 },
                            depth = 2,
                            color_key = ck,
                        },
                        cfg.tall_res[1], cfg.tall_res[2]
                    )
                end
            end
        else
            helpers.res_mirror(
                {
                    src = { x = 44, y = 15978, w = 340, h = 221 },
                    dst = { x = cfg.tall_pie.x, y = cfg.tall_pie.y, w = 420 * cfg.tall_pie.size / 4, h = 273 * cfg.tall_pie.size / 4 },
                    depth = 2,
                },
                cfg.tall_res[1], cfg.tall_res[2]
            )
        end
    end

    if cfg.tall_percent.enabled then
        if cfg.tall_percent.colorkey then
            if cfg.use_shaders then
                helpers.res_mirror(
                    {
                        src = { x = 291, y = 16163, w = 33, h = 25 },
                        dst = { x = cfg.tall_percent.x, y = cfg.tall_percent.y, w = 33 * cfg.tall_percent.size, h = 25 * cfg.tall_percent.size },
                        depth = 3,
                        shader = cfg.percentages_match_text and "text" or "percentages",
                    },
                    cfg.tall_res[1], cfg.tall_res[2]
                )
            else
                for _, ck in ipairs(percentage_colors) do
                    helpers.res_mirror(
                        {
                            src = { x = 291, y = 16163, w = 33, h = 25 },
                            dst = { x = cfg.tall_percent.x, y = cfg.tall_percent.y, w = 33 * cfg.tall_percent.size, h = 25 * cfg.tall_percent.size },
                            depth = 3,
                            color_key = ck,
                        },
                        cfg.tall_res[1], cfg.tall_res[2]
                    )
                end
            end
        else
            helpers.res_mirror(
                {
                    src = { x = 291, y = 16163, w = 33, h = 25 },
                    dst = { x = cfg.tall_percent.x, y = cfg.tall_percent.y, w = 33 * cfg.tall_percent.size, h = 25 * cfg.tall_percent.size },
                    depth = 3,
                },
                cfg.tall_res[1], cfg.tall_res[2]
            )
        end
    end

    helpers.res_mirror(
        {
            src = cfg.stretched_measure
                and { x = (cfg.tall_res[1] - 30) / 2, y = (cfg.tall_res[2] - 580) / 2, w = 30, h = 580 }
                or { x = (cfg.tall_res[1] - 60) / 2, y = (cfg.tall_res[2] - 580) / 2, w = 60, h = 580 },
            dst = { x = cfg.measuring_window.x, y = cfg.measuring_window.y, w = 70 * cfg.measuring_window.size, h = 40 * cfg.measuring_window.size },
            depth = 2,
        },
        cfg.tall_res[1], cfg.tall_res[2]
    )

    -- ==== IMAGES ====
    helpers.res_image(
        cfg.stretched_measure and paths.stretched_overlay or paths.overlay,
        {
            dst = { x = cfg.measuring_window.x, y = cfg.measuring_window.y, w = 70 * cfg.measuring_window.size, h = 40 * cfg.measuring_window.size },
            depth = 3,
        },
        cfg.tall_res[1], cfg.tall_res[2]
    )
    helpers.res_image(
        paths.tall_overlay,
        {
            dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
            depth = 1,
        },
        cfg.tall_res[1], cfg.tall_res[2]
    )
    helpers.res_image(
        paths.wide_overlay,
        {
            dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
            depth = 1,
        },
        cfg.wide_res[1], cfg.wide_res[2]
    )
    helpers.res_image(
        paths.thin_overlay,
        {
            dst = { x = 0, y = 0, w = cfg.resolution[1], h = cfg.resolution[2] },
            depth = 1,
        },
        cfg.thin_res[1], cfg.thin_res[2]
    )
end
