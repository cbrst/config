local wezterm = require("wezterm")

local M = {}

-- is mac?
M.is_mac = wezterm.target_triple == "aarch64-apple-darwin"

-- Automatically set color scheme based on light/dark mode
M.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

M.is_dark = function()
	return M.get_appearance():find("Dark")
end

M.scheme_for_appearance = function(dark, light)
	if M.is_dark() then
		return dark
	end
	return light
end

-- wrapper for SpawnCommand, since MacOS' default PATH is crap
M.spawn = function(args)
	local spawn = {
		os.getenv("SHELL"),
		"-c",
	}

	for _, arg in ipairs(args) do
		table.insert(spawn, wezterm.shell_quote_arg(arg))
	end

	return spawn
end

return M
