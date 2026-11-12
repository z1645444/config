return {
  -- Show hidden and gitignored files in the sidebar file tree by default.
  -- Toggle at runtime with `H` (hidden) and `I` (ignored) inside the explorer.
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
