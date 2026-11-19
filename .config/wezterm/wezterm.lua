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
config.font_size = 16.0
config.font = wezterm.font("Maple Mono Normal NF CN")
config.harfbuzz_features = { "calt=0", "zero" }

-- sweet warning
config.warn_about_missing_glyphs = false

-- hide tab bar if only one tab
config.hide_tab_bar_if_only_one_tab = true

-- set window decoration
config.window_decorations = "RESIZE"

-- Treat Option as Alt so key combos are sent to the terminal instead of composing characters
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

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
	-- Option + Left/Right: word-wise movement (same as Alt-b / Alt-f)
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"),
	},
	-- Option + Backspace: delete previous word
	{
		key = "Backspace",
		mods = "OPT",
		action = wezterm.action.SendString("\x1b\x7f"),
	},
	-- Option + Delete: delete next word
	{
		key = "Delete",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bd"),
	},
	{
		key = "[",
		mods = "SUPER|SHIFT|ALT",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		key = "]",
		mods = "SUPER|SHIFT|ALT",
		action = wezterm.action.MoveTabRelative(1),
	},
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action({ SendString = "\x1b\r" }),
	},
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = wezterm.action.Nop,
	},
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = wezterm.action.Nop,
	},
}

return config

