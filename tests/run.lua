-- ==== TESTS: smoke test dengan waywall API di-stub ====
-- Jalankan: luajit tests/run.lua (dari root waywall/)
-- Mencakup semua file yang ditulis: config/*, modules/*, main.lua, init.lua.
-- remaps.lua & extras.lua cukup syntax check (T-13.4).

local root = (arg and arg[0] and arg[0]:match("^(.*)[/\\][^/\\]+$") and (arg[0]:match("^(.*)[/\\][^/\\]+$") .. "/../")) or (os.getenv("HOME") .. "/.config/waywall/")

local function die(msg)
    print("FAIL: " .. msg)
    os.exit(1)
end

local passed, failed = 0, 0
local function ok(cond, msg)
    if cond then
        passed = passed + 1
    else
        failed = failed + 1
        print("FAIL: " .. msg)
    end
end

-- ==== 1. STUB waywall + helpers (record calls) ====
local calls = {}
local function record(name, ...)
    calls[#calls + 1] = { name = name, args = { ... } }
    return calls[#calls]
end

local current_res = { 0, 0 }
local waywall = {
    listen = function(ev, fn) record("listen", ev, fn) end,
    text = function(content, opts)
        record("text", content, opts)
        return { close = function() end }
    end,
    set_resolution = function(w, h)
        record("set_resolution", w, h)
        current_res = { w, h }
    end,
    active_res = function()
        record("active_res")
        return current_res[1], current_res[2]
    end,
    exec = function(cmd) record("exec", cmd) end,
    set_sensitivity = function(v) record("set_sensitivity", v) end,
    set_raw_sensitivity = function(v) record("set_raw_sensitivity", v) end,
    show_floating = function(v) record("show_floating", v) end,
    toggle_fullscreen = function() record("toggle_fullscreen") end,
    get_key = function(k) record("get_key", k); return false end,
    set_remaps = function(r) record("set_remaps", r) end,
    set_keymap = function(k) record("set_keymap", k) end,
    sleep = function(ms) record("sleep", ms) end,
}
package.loaded.waywall = waywall
package.loaded["waywall.helpers"] = {
    res_mirror = function(opts, w, h) record("res_mirror", opts, w, h) end,
    res_image = function(path, opts, w, h) record("res_image", path, opts, w, h) end,
    ingame_only = function(f) record("ingame_only", f); return f end,
    toggle_floating = function() record("toggle_floating") end,
}

-- ==== 2. cfg dibangun dari require config/* ASLI ====
local cfg = {}
for _, part in ipairs({
    require("config.looks"),
    require("config.mirrors"),
    require("config.macros"),
    require("config.keyboard"),
    require("config.misc"),
}) do
    for k, v in pairs(part) do cfg[k] = v end
end

-- ==== 3. load main ====
local remaps_fixture = {}
local config = require("main")(cfg, remaps_fixture)
assert(type(config) == "table", "main() harus return config table")

-- ==== 4. STRUKTUR ====
-- 4a. semua key cfg ekspektasi (dari init.lua asli) ada di gabungan
local expected_keys = {
    "debug_text", "resolution", "bg_col", "toggle_bg_picture", "text_col",
    "pie_chart_1", "pie_chart_2", "pie_chart_3", "ninbot_anchor", "ninbot_opacity",
    "thin_res", "wide_res", "tall_res", "e_count", "thin_pie", "tall_pie",
    "thin_percent", "tall_percent", "percentages_match_text", "measuring_window",
    "stretched_measure", "use_shaders", "thin", "wide", "tall",
    "toggle_fullscreen_key", "launch_paceman_key", "toggle_ninbot_key", "toggle_remaps_key",
    "xkb_config", "remaps_text_config", "sens_change", "enable_resize_animations",
    "autostart_ninbot", "autostart_paceman",
}
local missing = {}
for _, k in ipairs(expected_keys) do
    if cfg[k] == nil then missing[#missing + 1] = k end
end
ok(#missing == 0, "cfg key hilang: " .. table.concat(missing, ", "))

-- 4b. config.input / theme / window
ok(config.input ~= nil, "config.input ada")
ok(config.input.remaps == remaps_fixture, "config.input.remaps = remaps")
ok(config.input.sensitivity == cfg.sens_change.normal, "config.input.sensitivity")
ok(config.input.layout == nil, "config.input.layout nil (xkb disabled)")
ok(config.input.repeat_rate == 40, "config.input.repeat_rate")
ok(config.theme ~= nil, "config.theme ada")
ok(config.theme.background == cfg.bg_col, "config.theme.background")
ok(config.theme.background_png ~= nil, "config.theme.background_png (toggle_bg_picture=true)")
ok(config.theme.ninb_anchor == cfg.ninbot_anchor, "config.theme.ninb_anchor")
ok(config.theme.ninb_opacity == cfg.ninbot_opacity, "config.theme.ninb_opacity")
ok(config.window ~= nil, "config.window ada")
ok(config.window.fullscreen_width == cfg.resolution[1], "config.window.width")
ok(config.window.fullscreen_height == cfg.resolution[2], "config.window.height")
ok(config.experimental ~= nil, "config.experimental ada")

-- 4c. config.actions punya semua keybind
local expected_actions = {
    cfg.thin.key, cfg.wide.key, cfg.tall.key,
    cfg.toggle_fullscreen_key, cfg.launch_paceman_key,
    cfg.toggle_ninbot_key, cfg.toggle_remaps_key, "Shift-I",
}
local action_missing = {}
for _, k in ipairs(expected_actions) do
    if type(config.actions[k]) ~= "function" then action_missing[#action_missing + 1] = tostring(k) end
end
ok(#action_missing == 0, "action hilang: " .. table.concat(action_missing, ", "))

-- ==== 5. RESOLUSI (T-13.2) ====
local sens_calls = {}
local old_set_sens = waywall.set_sensitivity
local sens_rec = {}
waywall.set_sensitivity = function(v) sens_rec[#sens_rec + 1] = v end
waywall.set_raw_sensitivity = function(v) sens_rec[#sens_rec + 1] = v end

-- thin: active (0,0) -> set 340x1080 + sens normal
current_res = { 0, 0 }
config.actions[cfg.thin.key]()
ok(current_res[1] == 340 and current_res[2] == 1080, "thin -> 340x1080 (got " .. current_res[1] .. "x" .. current_res[2] .. ")")
ok(sens_rec[#sens_rec] == cfg.sens_change.normal, "thin -> sens normal")
-- thin lagi: aktif -> reset 0x0
config.actions[cfg.thin.key]()
ok(current_res[1] == 0 and current_res[2] == 0, "thin toggle -> 0x0 (got " .. current_res[1] .. "x" .. current_res[2] .. ")")

-- wide: -> 1920x300 + sens normal
current_res = { 0, 0 }
config.actions[cfg.wide.key]()
ok(current_res[1] == 1920 and current_res[2] == 300, "wide -> 1920x300 (got " .. current_res[1] .. "x" .. current_res[2] .. ")")
ok(sens_rec[#sens_rec] == cfg.sens_change.normal, "wide -> sens normal")

-- tall: -> 384x16384 + sens tall
current_res = { 0, 0 }
config.actions[cfg.tall.key]()
ok(current_res[1] == 384 and current_res[2] == 16384, "tall -> 384x16384 (got " .. current_res[1] .. "x" .. current_res[2] .. ")")
ok(sens_rec[#sens_rec] == cfg.sens_change.tall, "tall -> sens tall")

-- ingame_only thin: resize_helper pakai helpers.ingame_only (stub pass-through)
ok(#calls > 0, "ada calls tercatat")

-- ==== 6. MIRRORS (T-13.3) ====
local mirror_count, image_count = 0, 0
for _, c in ipairs(calls) do
    if c.name == "res_mirror" then mirror_count = mirror_count + 1 end
    if c.name == "res_image" then image_count = image_count + 1 end
end
-- fixture: e_count(2) + thin_pie(1) + thin_percent(1) + tall_pie(1) + tall_percent(1) + measuring(1) = 7
ok(mirror_count == 7, "res_mirror count = 7 (got " .. mirror_count .. ")")
ok(image_count == 4, "res_image count = 4 (got " .. image_count .. ")")

-- ==== 7. SYNTAX CHECK SEMUA .lua (T-13.4) ====
local function syntax_ok(rel)
    local p = io.popen("luajit -bl " .. root .. rel .. " 2>&1")
    local out = p:read("*a")
    local okcode = p:close()
    return okcode == true, out
end
local lua_files = {
    "init.lua", "main.lua", "remaps.lua", "extras.lua",
    "config/looks.lua", "config/mirrors.lua", "config/macros.lua", "config/keyboard.lua", "config/misc.lua",
    "modules/tools.lua", "modules/mirrors.lua", "modules/resolutions.lua", "modules/actions.lua",
}
for _, rel in ipairs(lua_files) do
    local okcode, out = syntax_ok(rel)
    ok(okcode, "syntax: " .. rel .. (not okcode and ("\n" .. out) or ""))
end

-- ==== 8. GEN-DOCS (M-02) ====
-- gen-docs harus jalan tanpa error dan regenerasi docs identik (idempoten).
local function run_gen_docs()
    local p = io.popen("luajit " .. root .. "scripts/gen-docs.lua 2>&1")
    local out = p:read("*a")
    local okcode = p:close()
    return okcode == true or okcode == 0, out
end
local before1 = io.open(root .. "docs/remaps.md", "r"):read("*a")
local before2 = io.open(root .. "docs/macros.md", "r"):read("*a")
local okcode, out = run_gen_docs()
ok(okcode, "gen-docs jalan tanpa error" .. (not okcode and ("\n" .. out) or ""))
local after1 = io.open(root .. "docs/remaps.md", "r"):read("*a")
local after2 = io.open(root .. "docs/macros.md", "r"):read("*a")
ok(after1 == before1 and after2 == before2, "gen-docs idempoten")

-- ==== 9. SUMMARY ====
print("")
print("RESULT: " .. passed .. " passed, " .. failed .. " failed")
if failed > 0 then
    os.exit(1)
end
print("ALL TESTS PASSED")
