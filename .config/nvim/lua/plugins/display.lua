return {
  -- Gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- stfu pyright
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
      },
    },
  },

  -- notifier: 弹窗移到右下角 + 光标聚焦快捷键
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { position = "bottom_right" },
    },
    keys = {
      {
        "<leader>ne",
        function()
          local target
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(w)
            if vim.bo[buf].filetype == "snacks_notif" then
              target = w
            end
          end
          if target then
            vim.api.nvim_set_current_win(target)
          else
            Snacks.notifier.show_history()
          end
        end,
        desc = "Focus Notification Popup",
      },
    },
  },
}

