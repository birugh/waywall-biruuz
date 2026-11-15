-- ==== WAYWALL GENERIC CONFIG ====
local main = require("main")
local remaps = require("remaps")

-- ==== CONFIG ====
local cfg = {}
for _, part in ipairs({
	require("config.looks"),
	require("config.mirrors"),
	require("config.macros"),
	require("config.keyboard"),
	require("config.misc"),
}) do
	for k, v in pairs(part) do
		cfg[k] = v
	end
end

return main(cfg, remaps)
