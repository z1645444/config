-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- color scheme
config.color_scheme = "Gruvbox dark, hard (base16)"

-- font
config.font_size = 20.0
config.font = wezterm.font_with_fallback({
	-- "Comic Code",
	"FiraCode Nerd Font",
	"Fira Code",
	"Pingfang",
	"Source Han Sans",
})

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- sweet warning
config.warn_about_missing_glyphs = false

-- hide tab bar if only one tab
config.hide_tab_bar_if_only_one_tab = true

-- set window decoration
config.window_decorations = "RESIZE"

-- key bind
config.keys = {
	{
		key = "UpArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollByPage(-0.5),
	},
	{
		key = "DownArrow",
		mods = "SHIFT",
		action = wezterm.action.ScrollByPage(0.5),
	},
}

-- SSH config
-- config.ssh_domains = {
--     {
--         name = 'localhost',
--         remote_address = '127.0.0.1',
--         username = 'root',
--         -- Specify an alternative read timeout -> MINUTES OR HOURS?
--         timeout = 60,
--     },
-- }

-- and finally, return the configuration to wezterm
return config
