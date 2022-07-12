local wezterm = require 'wezterm';

return {
  font_size = 12.0,
  color_scheme = "Gruvbox Dark",
  font = wezterm.font_with_fallback({
    "Fira Code",
    "Source Han Sans SC VF",
  }),

  hide_tab_bar_if_only_one_tab = true,
  warn_about_missing_glyphs=false,
}
