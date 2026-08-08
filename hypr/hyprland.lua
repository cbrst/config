-- Hyprland owns window management while Noctalia supplies the complete desktop shell.

local main_mod = "SUPER"

-- Define session-wide defaults once; launch-default consumes these values for keybindings.
hl.env("TERMINAL", "Ghostty")
hl.env("BROWSER", "firefox")
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

-- Use the display's preferred mode until a user adds a machine-specific monitor rule.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

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
        layout = "dwindle",
    },

    decoration = {
        -- Rounded, subtly translucent windows complement Noctalia without obscuring content.
        rounding = 14,
        rounding_power = 3,
        active_opacity = 0.98,
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
            range = 18,
            render_power = 3,
            color = "rgba(00000080)",
        },
    },

    dwindle = {
        -- Preserve split direction to make tiling behavior predictable.
        preserve_split = true,
    },

    master = {
        -- Do not displace the focused window when creating a new one.
        new_status = "master",
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

-- Curves retain polish while faster speeds avoid Hyprland's sluggish default feel.
hl.curve("swift", { type = "bezier", points = { { 0.2, 0.85 }, { 0.25, 1.0 } } })
hl.curve("easeout", { type = "bezier", points = { { 0.16, 1.0 }, { 0.3, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 9, bezier = "swift", style = "popin 86%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 8, bezier = "easeout", style = "popin 86%" })
hl.animation({ leaf = "border", enabled = true, speed = 12, bezier = "easeout" })
hl.animation({ leaf = "fade", enabled = true, speed = 8, bezier = "easeout" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "swift", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 8, bezier = "swift", style = "slidevert" })

-- Start the shell after the compositor has created its Wayland and D-Bus session state.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE")
    hl.exec_cmd("noctalia")
end)

-- Default-program bindings defer expansion to the session environment, not this config's literals.
hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default terminal"))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default browser"))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/launch-default file-manager"))
hl.bind(main_mod .. " + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(main_mod .. " + C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())
hl.bind(main_mod .. " + V", hl.dsp.layout("togglesplit"))

-- Arrow keys change focus or move the active window when Shift is held.
local directions = {
    left = "left",
    right = "right",
    up = "up",
    down = "down",
}
for key, direction in pairs(directions) do
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

-- Number keys switch workspaces; Shift sends the active window to that workspace.
for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Pointer actions remain available without traditional title bars.
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Noctalia observes the PipeWire changes below and presents them through its OSD.
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Keep common utility dialogs centered and out of the tiled layout.
hl.window_rule({
    name = "float-utility-dialogs",
    match = { class = "^(pavucontrol|blueman-manager|nm-connection-editor)$" },
    float = true,
    center = true,
})
