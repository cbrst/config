local wezterm = require("wezterm")
local keybindings = require("keybindings")
local util = require("util")
local config = wezterm.config_builder()

config.animation_fps = 60
config.audible_bell = "Disabled"

-- this is nice, but for some reason disables shadows
-- if util.is_mac then
-- 	config.window_background_opacity = 0.8
-- 	config.macos_window_background_blur = 20
-- end

-- font
local fontFamily = "CommitMono"
local fontFamilyItalic = "CommitMono"
config.font = wezterm.font({
	family = fontFamily,
})
config.font_size = 11
config.line_height = 1.2
-- This font includes Powerline/Nerd Font glyphs, so zsh can use the full prompt.
config.set_environment_variables = {
	CONFIG_POWERLINE_GLYPHS = "1",
}
config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = fontFamily,
			weight = "Bold",
		}),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = fontFamilyItalic,
			style = "Italic",
		}),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = fontFamilyItalic,
			weight = "Bold",
			style = "Italic",
		}),
	},
}

-- Bigger font size on MacBook
if util.is_mac then
	config.font_size = 14
end

local family = util.theme_family()
local schemes = {
	meowsoot = { dark = "meowsoot", light = "meowsoot-dawn" },
	["monokai-pro"] = { dark = "monokai-pro-spectrum", light = "monokai-pro-light" },
}
-- The state file changes independently of OS appearance; WezTerm watches it for reloads.
config.color_scheme = util.scheme_for_appearance(schemes[family].dark, schemes[family].light)

-- I don't hit the quit keybind accidentally
config.window_close_confirmation = "NeverPrompt"

-- Compose is alt on Mac. Or is it the other way around?
-- Don't remember. It works.
if util.is_mac then
	config.send_composed_key_when_left_alt_is_pressed = true
	config.send_composed_key_when_right_alt_is_pressed = false
	config.use_dead_keys = true
end

-- Set tab bar colors from active color scheme
wezterm.on("window-config-reloaded", function(window, _)
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground
	local inactive_bg = color_scheme.ansi[1]
	local inactive_hover = wezterm.color.parse(inactive_bg)
	if util.is_dark() then
		inactive_hover = inactive_hover:lighten(0.1)
	else
		inactive_hover = inactive_hover:darken(0.1)
	end
	local font_size = 10
	if util.is_mac then
		font_size = 12
	end

	window:set_config_overrides({
		colors = {
			tab_bar = {
				inactive_tab_edge = bg,
				active_tab = {
					bg_color = bg,
					fg_color = fg,
				},
				inactive_tab = {
					bg_color = inactive_bg,
					fg_color = fg,
				},
				inactive_tab_hover = {
					bg_color = inactive_hover,
					fg_color = fg,
				},
			},
		},
		window_frame = {
			font = wezterm.font({ family = fontFamily, weight = "Bold" }),
			font_size = font_size,
			inactive_titlebar_bg = inactive_bg,
			active_titlebar_bg = inactive_bg,
		},
	})
end)

-- Fancy-shmancy
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_resize_increments = false
config.window_padding = {
	left = 5,
	right = 5,
	top = 0,
	bottom = 0,
}

-- Titlebar buttons
if util.is_mac then
	-- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
	config.window_decorations = "RESIZE"
	config.integrated_title_button_style = "MacOsNative"
else
	config.window_decorations = "TITLE | RESIZE"
	config.integrated_title_button_style = "Windows"
end
config.integrated_title_button_alignment = "Left"
config.integrated_title_buttons = {
	"Close",
	"Maximize",
	"Hide",
}

-- Little hack.
-- Display an empty left status to add some spacing between tabs and integrated buttons
wezterm.on("update-right-status", function(window, _)
	window:set_left_status(wezterm.format({
		{ Background = { Color = "none" } },
		{ Text = " " },
	}))
end)

-- Keybindings
config.leader = keybindings.leader
config.keys = keybindings.keys
config.key_tables = keybindings.key_tables

-- Statusbar
require("statusbar").build_statusbar()

-- Bring new windows to the front
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():focus()
end)

return config
