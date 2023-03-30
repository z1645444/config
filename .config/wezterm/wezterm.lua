-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- color scheme
config.color_scheme = 'Gruvbox dark, medium (base16)'

-- font
config.font_size = 14.0
config.font = wezterm.font_with_fallback({"Fira Code", "Pingfang"})

-- sweet warning
config.warn_about_missing_glyphs = false

-- hide tab bar if only one tab
config.hide_tab_bar_if_only_one_tab = true

-- key bind
config.keys = {
    {
        key = 'UpArrow',
        mods = "CMD",
        action = wezterm.action.ScrollByPage(-0.5)
    },
    {
        key = "DownArrow",
        mods = "CMD",
        action = wezterm.action.ScrollByPage(0.5)
    },
}

-- and finally, return the configuration to wezterm
return config

