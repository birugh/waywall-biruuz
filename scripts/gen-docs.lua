-- scripts/gen-docs.lua
-- Generate docs/remaps.md & docs/macros.md dari remaps.lua dan config/macros.lua.
-- Jalankan dari mana saja: luajit scripts/gen-docs.lua

local script_dir = arg[0]:match("^(.*)[/\\][^/\\]+$") or "."
local root = script_dir .. "/.."
-- script_dir = "<root>/scripts", jadi root = script_dir/..

local function die(msg, line)
    io.stderr:write("ERROR: " .. msg .. (line and (" (baris " .. line .. ")") or "") .. "\n")
    os.exit(1)
end

local function read_lines(path)
    local f, err = io.open(path, "r")
    if not f then die("tidak bisa buka " .. path .. ": " .. err) end
    local lines = {}
    for l in f:lines() do lines[#lines + 1] = l end
    f:close()
    return lines
end

-- Parser generik untuk file berbentuk `return { ... }` dengan
-- komentar `-- ==== X ====` (judul dokumen) dan `-- teks` (judul grup/kategori).
-- parse_entry(line) -> from, to atau nil
local function parse_file(path, file_title, parse_entry)
    local lines = read_lines(path)
    local title = file_title
    local groups = {}       -- { title, line, entries = {} }
    local cur = nil
    local pending_comment = nil -- nomor baris komentar yang belum punya entri
    local seen_title = false

    for i, raw in ipairs(lines) do
        local line = raw:match("^%s*(.-)%s*$")
        if line ~= "" then
            if line == "return {" or line == "}" then
                -- kurung pembuka/penutup tabel
            elseif line:match("^%s*%-%-%s*====%s*(.-)%s*====%s*$") then
                local t = line:match("^%s*%-%-%s*====%s*(.-)%s*====%s*$")
                if seen_title then die("judul dokumen ganda", i) end
                if groups[1] or cur then die("judul dokumen harus di awal file", i) end
                title = t
                seen_title = true
            elseif line:match("^%s*%-%-%s*%[") then
                die("entri yang di-comment tidak didukung; aktifkan atau hapus", i)
            elseif line:match("^%s*%-%-") then
                local gtitle = line:match("^%s*%-%-%s*(.-)%s*$")
                if pending_comment then
                    die("komentar tanpa entri setelahnya (komentar baris " .. pending_comment .. ")", i)
                end
                cur = { title = gtitle, line = i, entries = {} }
                groups[#groups + 1] = cur
                pending_comment = i
            else
                local from, to = parse_entry(line)
                if not from then die("baris tidak dikenal", i) end
                if not cur then die("entri tanpa judul grup", i) end
                cur.entries[#cur.entries + 1] = { from = from, to = to }
                pending_comment = nil
            end
        end
    end
    if pending_comment then die("komentar tanpa entri (baris " .. pending_comment .. ")", #lines) end
    return title, groups
end

-- ==== remaps.lua ====
local function parse_remaps_entry(line)
    local from, to = line:match('^%s*%[%s*"([^"]+)"%s*%]%s*=%s*"([^"]+)"%s*,?%s*$')
    return from, to
end

-- ==== config/macros.lua ====
local function parse_macros_entry(line)
    local name, key = line:match('^%s*([%w_]+)%s*=%s*"([^"]+)"%s*,?%s*$')
    if name then return name, key end
    name, key = line:match('^%s*([%w_]+)%s*=%s*{%s*key%s*=%s*"([^"]+)"')
    if name then return name, key end
    return nil, nil
end

-- Deskripsi Indonesia per judul grup/kategori (gaya humanizer).
-- Judul tanpa entri di peta ini = tanpa deskripsi, tetap jadi heading.
local DESCRIPTIONS = {
    -- remaps
    ["crafts: ow, wo, got"] = "Menukar A dan O untuk craft ow, wo, dan got.",
    ["move to root in piechart"] = "Tombol grave dan 0 saling bertukar untuk pindah ke root di piechart.",
    ["remove word"] = "Tombol 2 dan backspace saling bertukar untuk menghapus satu kata.",
    ["craft: ket"] = "Menukar Z dan K untuk craft ket.",
    ["craft: rm"] = "Tombol 3 jadi M untuk craft rm.",
    ["craft: tn"] = "Tombol 5 jadi N untuk craft tn.",
    ["craft: sh"] = "Tombol 1 jadi H untuk craft sh.",
    ["crafts: ie, wi"] = "Menukar I dan Q untuk craft ie dan wi.",
    ["crafts: be, bre, br, bo, sb"] = "Menukar D dan B untuk craft be, bre, br, bo, dan sb.",
    ["crafts: el, fl"] = "Menukar L dan V untuk craft el dan fl.",
    ["crafts: pp, esp"] = "Menukar P dan C untuk craft pp dan esp.",
    ["to easily open piechart, also without crouching"] = "RIGHTSHIFT dan MOUSE4 saling bertukar supaya piechart mudah dibuka, juga tanpa crouch.",
    ["to select words from end to the beginning"] = "MOUSE5 dan HOME saling bertukar untuk memilih kata dari akhir ke awal.",
    ["piechart"] = "Tombol piechart: 6 ke 1, Y ke 2, H ke 3, N ke 5.",
    -- macros
    ["resolution changes"] = "Macro ganti resolusi layar: thin, wide, dan tall.",
    ["startup actions"] = "Aksi yang jalan saat startup: toggle fullscreen dan buka Paceman.",
    ["during game actions"] = "Aksi saat main: toggle Ninjabrain Bot dan toggle remaps.",
}

local function write_doc(path, doc_title, source_rel, groups, col1, col2)
    local out = { "# " .. doc_title, "", "Dokumen ini dibuat otomatis dari `" .. source_rel .. "` oleh `scripts/gen-docs.lua`. Edit sumbernya, bukan file ini.", "" }
    for _, g in ipairs(groups) do
        out[#out + 1] = "## " .. g.title
        local desc = DESCRIPTIONS[g.title]
        if desc then
            out[#out + 1] = ""
            out[#out + 1] = desc
        end
        out[#out + 1] = ""
        out[#out + 1] = "| " .. col1 .. " | " .. col2 .. " |"
        out[#out + 1] = "| --- | --- |"
        for _, e in ipairs(g.entries) do
            out[#out + 1] = "| `" .. e.from .. "` | `" .. e.to .. "` |"
        end
        out[#out + 1] = ""
    end
    -- pastikan docs/ ada
    os.execute("mkdir -p " .. root .. "/docs")
    local f, err = io.open(root .. "/docs/" .. path, "w")
    if not f then die("tidak bisa tulis docs/" .. path .. ": " .. err) end
    f:write(table.concat(out, "\n"))
    f:close()
    print("docs/" .. path .. " diperbarui")
end

local remaps_title, remaps_groups = parse_file(root .. "/remaps.lua", "Remaps", parse_remaps_entry)
local macros_title, macros_groups = parse_file(root .. "/config/macros.lua", "Macros", parse_macros_entry)

write_doc("remaps.md", remaps_title, "remaps.lua", remaps_groups, "Tombol", "Jadi")
write_doc("macros.md", macros_title, "config/macros.lua", macros_groups, "Aksi", "Tombol")
