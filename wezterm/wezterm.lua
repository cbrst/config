local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- local appearance = require 'appearance'
local projects = require("projects")

config.color_scheme = "Tokyo Night Storm"
config.font = wezterm.font("Cartograph CF")
config.font_size = 10
config.line_height = 1.1

config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false

config.window_decorations = "TITLE | RESIZE"
config.window_frame = {
	font = wezterm.font({ family = "Cartograph CF", weight = "Bold" }),
	font_size = 10,
	inactive_titlebar_bg = "#1d202f",
	active_titlebar_bg = "#1d202f",
}
config.colors = {
	tab_bar = {
		active_tab = {
			bg_color = "#24283b",
			fg_color = "#c0caf5",
		},
		inactive_tab = {
			bg_color = "#1d202f",
			fg_color = "#545c7e",
		},
	},
}
config.integrated_title_button_style = "Windows"
config.integrated_title_button_alignment = "Left"
config.integrated_title_buttons = {
	"Close",
	"Maximize",
	"Hide",
}

local function segments_for_right_status(window)
	return {
		window:active_workspace(),
		wezterm.strftime("%a %b %-d %H:%M"),
		wezterm.hostname(),
	}
end

wezterm.on("update-status", function(window, _)
	local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
	local segments = segments_for_right_status(window)

	local color_scheme = window:effective_config().resolved_palette
	local bg = wezterm.color.parse(color_scheme.background)
	local fg = color_scheme.foreground

	local gradient_to, gradient_from = bg, bg
	gradient_from = gradient_to:lighten(0.2)

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

local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Pass through CTRL+A
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},

	{
		key = ",",
		mods = "SUPER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { "nvim", wezterm.config_file },
		}),
	},

	{
		key = "\\",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	move_pane("h", "Left"),
	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("l", "Right"),

	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			one_shot = false,
			timeout_milliseconds = 1000,
		}),
	},

	{
		key = "p",
		mods = "LEADER",
		action = projects.choose_project(),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
}

config.key_tables = {
	resize_panes = {
		resize_pane("h", "Left"),
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("l", "Right"),
	},
}

return config
