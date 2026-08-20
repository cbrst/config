-- ┌────────────────────────┐
-- │ Core editor setup      │
-- └────────────────────────┘
require("config.globals").setup()
require("options")
require("keymap")
require("autocmds")
require("languages").setup()

-- ┌────────────────────────┐
-- │ Plugins and appearance │
-- └────────────────────────┘
require("plugins").setup()

-- Apply the theme after every startup plugin has defined its highlight groups.
require("config.theme").set_colorscheme()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
