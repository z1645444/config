return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = {
            "--config",
            vim.fn.expand("~/.config/nvim/markdownlint.json"),
          },
        },
        prettier = {
          prepend_args = {
            "--print-width",
            "160",
            "--semi",
            "--tab-width",
            "2",
            "--single-quote",
            "--trailing-comma",
            "all",
            "--arrow-parens",
            "always",
            "--bracket-spacing",
            "--end-of-line",
            "lf",
            "--html-whitespace-sensitivity",
            "css",
            "--embedded-language-formatting",
            "auto",
            "--prose-wrap",
            "preserve",
            "--jsx-bracket-same-line",
            "false",
            "--bracket-same-line",
            "false",
            "--quote-props",
            "as-needed",
            "--single-attribute-per-line",
            "--vue-indent-script-and-style",
            "false",
          },
        },
        trailing_blank_line = {
          format = function(_, _, lines, callback)
            if lines[#lines] ~= "" then
              table.insert(lines, "")
            end
            callback(nil, lines)
          end,
        },
      },
      formatters_by_ft = {
        ["*"] = { "trailing_blank_line" },
      },
    },
  },
}
