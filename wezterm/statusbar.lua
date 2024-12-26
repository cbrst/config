local wezterm = require("wezterm")
local util = require("util")

local M = {}

local function replace_path_elements(path)
	local replacements = {
		[os.getenv("HOME")] = "~",
		["%%20"] = " ",
		["~/Documents"] = wezterm.nerdfonts.md_file_document,
		["~/Downloads"] = wezterm.nerdfonts.md_cloud_download,
		["~/Projects/config"] = wezterm.nerdfonts.seti_config,
		["~/Projects"] = wezterm.nerdfonts.md_code_braces_box,
	}
	for key, value in pairs(replacements) do
		path = path:gsub(key, value)
	end
	return path
end

-- Fancy statusbar
M.build_statusbar = function()
	local function segments_for_right_status(window, pane)
		local hostname = ""
		hostname = wezterm.hostname()

		-- if a full hostname is returned, only use the first part
		local period = hostname:find("%.")
		if period then
			hostname = hostname:sub(1, period - 1)
		end

		return {
			-- replace_path_elements(pane:get_current_working_dir().path),
			window:active_workspace(),
			hostname,
		}
	end

	wezterm.on("update-status", function(window, pane)
		local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
		-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
		-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
		local segments = segments_for_right_status(window, pane)

		local color_scheme = window:effective_config().resolved_palette
		local bg = wezterm.color.parse(color_scheme.background)
		local fg = color_scheme.foreground

		local gradient_to, gradient_from = bg, bg

		if util.is_dark() then
			gradient_to = bg:lighten(0.3)
			gradient_from = bg:lighten(0.15)
		else
			gradient_to = bg:darken(0.15)
			gradient_from = bg:darken(0.08)
		end

		local gradient = wezterm.color.gradient({
			orientation = "Horizontal",
			colors = { gradient_from, gradient_to },
		}, #segments)

		local elements = {}
		for i, seg in ipairs(segments) do
			local is_first = i == 1

			if is_first then
				table.insert(elements, { Background = { Color = "none" } })
			end

			table.insert(elements, { Foreground = { Color = gradient[i] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })

			table.insert(elements, { Foreground = { Color = fg } })
			table.insert(elements, { Background = { Color = gradient[i] } })
			table.insert(elements, { Text = " " .. seg .. " " })
		end
		window:set_right_status(wezterm.format(elements))
	end)
end

return M
