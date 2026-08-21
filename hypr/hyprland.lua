-- ╭─────────────────────────────────╮
-- │ Session Environment and Display │
-- ╰─═══════════════════════════════─╯
-- Hyprland owns window management while Noctalia supplies the complete desktop shell.

local MMOD = "SUPER"

-- Define session-wide defaults once; launch-default consumes these values for keybindings.
hl.env("TERMINAL", "ghostty")
-- Choose Firefox's compact profile only when Hyprland owns the session.
hl.env("BROWSER", "firefox-session")
hl.env("FILE_MANAGER", "nemo")
hl.env("EDITOR", "nvim")
hl.env("VISUAL", "nvim")

-- Prefer native Wayland backends for common toolkits while retaining XWayland compatibility.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xbe")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- Make the 1Password SSH agent available to graphical applications.
hl.env("SSH_AUTH_SOCK", "$HOME/.1password/agent.sock")
-- Use Bibata's familiar blue desktop cursor in Hyprland and inherited clients.
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
-- Keep Java AWT windows visible under a non-reparenting Wayland compositor.
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Use the display's preferred mode until a user adds a machine-specific monitor rule.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- ╭───────────────────────╮
-- │ Compositor Appearance │
-- ╰─═════════════════════─╯
hl.config({
	general = {
		-- Leave space for Noctalia's floating bar and give tiled windows breathing room.
		gaps_in = 5,
		gaps_out = 12,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
			inactive_border = "rgba(45475a99)",
		},
		resize_on_border = true,
		allow_tearing = false,
		layout = "scrolling",
	},

	decoration = {
		-- Rounded, subtly translucent windows complement Noctalia without obscuring content.
		rounding = 8,
		rounding_power = 3,
		active_opacity = 1.0,
		inactive_opacity = 0.92,
		dim_inactive = true,
		dim_strength = 0.06,
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			new_optimizations = true,
			xray = true,
			noise = 0.015,
			contrast = 0.95,
			brightness = 0.85,
			vibrancy = 0.18,
			vibrancy_darkness = 0.12,
		},
		shadow = {
			enabled = true,
			range = 28,
			render_power = 3,
			color = "rgba(00000020)",
		},
	},

	input = {
		-- Keep the default keyboard layout portable; add a device rule for local overrides.
		kb_layout = "us",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			drag_lock = true,
		},
	},

	misc = {
		-- Noctalia owns wallpaper, so hide Hyprland's branded fallback.
		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
		focus_on_activate = true,
	},

	xwayland = {
		-- Let XWayland applications follow the output scaling defined above.
		force_zero_scaling = true,
	},
})

-- ╭─────────╮
-- │ Layouts │
-- ╰─═══════─╯
hl.config({
	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	scrolling = {
		column_width = 0.5,
		explicit_column_widths = "0.2, 0.333, 0.5, 0.667, 0.8, 1.0",
		focus_fit_method = 1,
		follow_focus = 1,
		fullscreen_on_one_column = false,
		wrap_focus = false,
	},
})

-- ╭────────────╮
-- │ Animations │
-- ╰─══════════─╯
-- Curves retain polish while faster speeds avoid Hyprland's sluggish default feel.
hl.curve("swift", { type = "bezier", points = { { 0.2, 0.85 }, { 0.25, 1.0 } } })
hl.curve("easeout", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 9, bezier = "swift", style = "popin 86%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 8, bezier = "easeout", style = "popin 86%" })
hl.animation({ leaf = "border", enabled = true, speed = 12, bezier = "easeout" })
hl.animation({ leaf = "fade", enabled = true, speed = 8, bezier = "easeout" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "swift", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 8, bezier = "swift", style = "slidevert" })

-- ╭───────────────────╮
-- │ Session Lifecycle │
-- ╰─═════════════════─╯
-- Start the shell after the compositor has created its Wayland and D-Bus session state.
hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
	hl.exec_cmd("noctalia")
end)

-- ╭──────────╮
-- │ Bindings │
-- ╰─════════─╯
-- Prefix compositor bindings consistently while leaving global media keys unmodified.
local function bind(key, dispatcher, options)
	hl.bind(MMOD .. " + " .. key, dispatcher, options)
end

-- ╭───────────╮
-- │ Launchers │
-- ╰─═════════─╯
-- Default-program bindings defer expansion to the session environment, not this config's literals.
bind("Return", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default terminal"))
bind("Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

bind("X", hl.dsp.submap("launch"))
hl.define_submap("launch", "reset", function()
	hl.bind("B", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default browser"))
	hl.bind("E", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default file-manager"))
end)

-- ╭───────╮
-- │ Shell │
-- ╰─═════─╯
bind("S", hl.dsp.submap("shell"))
hl.define_submap("shell", "reset", function()
	hl.bind("C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
	hl.bind("L", hl.dsp.exec_cmd("noctalia msg session lock"))
	hl.bind("R", hl.dsp.exec_cmd("hyprctl reload"))
end)

-- ╭─────────────────────────────────╮
-- │ Window and Workspace Navigation │
-- ╰─═══════════════════════════════─╯
-- Arrow keys or hjkl change focus; Shift moves windows outside the scrolling layout.
local directions = {
	left = { "left", "h" },
	right = { "right", "l" },
	up = { "up", "k" },
	down = { "down", "j" },
}

for direction, keys in pairs(directions) do
	for _, key in ipairs(keys) do
		bind(key, hl.dsp.focus({ direction = direction }))
		bind("ALT + " .. key, hl.dsp.window.move({ direction = direction }))
	end
end

bind("SHIFT + H", hl.dsp.layout("swapcol l"))
bind("SHIFT + L", hl.dsp.layout("swapcol r"))
bind("SHIFT + left", hl.dsp.layout("swapcol l"))
bind("SHIFT + right", hl.dsp.layout("swapcol r"))

-- Number keys switch workspaces; Shift sends the active window to that workspace.
for workspace = 1, 10 do
	local key = workspace % 10
	bind(key, hl.dsp.focus({ workspace = workspace }))
	bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

bind("SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
bind("Q", hl.dsp.window.close())
bind("F", hl.dsp.window.fullscreen({ mode = 0 }))
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = 1 }))
bind("P", hl.dsp.window.pseudo())
bind("V", hl.dsp.layout("togglesplit"))

-- ╭──────────────────╮
-- │ Layout Selection │
-- ╰─════════════════─╯
-- Rotate the configured layouts without requiring a compositor reload.
bind(
	"T",
	hl.dsp.exec_cmd(
		"layout=$(hyprctl getoption general:layout | cut -d' ' -f2); "
			.. 'case "$layout" in scrolling) next=master ;; master) next=dwindle ;; *) next=scrolling ;; esac; '
			.. 'hyprctl keyword general:layout "$next"'
	)
)

-- bindings specific for column layout
bind("equal", hl.dsp.layout("colresize +conf"))
bind("minus", hl.dsp.layout("colresize -conf"))
bind("period", hl.dsp.layout("promote"))
bind("comma", hl.dsp.layout("consume"))

-- ╭───────────────────╮
-- │ Pointer and Media │
-- ╰─═════════════════─╯
-- Pointer actions remain available without traditional title bars.
bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Noctalia observes the PipeWire changes below and presents them through its OSD.
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- ╭──────────────╮
-- │ Window Rules │
-- ╰─════════════─╯
-- Keep common utility dialogs centered and out of the tiled layout.
hl.window_rule({
	name = "float-utility-dialogs",
	match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor)$" },
	float = true,
	center = true,
})

-- open firefox at 80% screen width
hl.window_rule({
	name = "firefox-starting-width",
	match = { class = "firefox" },
	scrolling_width = 0.8,
})

hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
	},
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
