return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local mclaren_theme = {
        normal = {
          a = { fg = "#000000", bg = "#ff6a00", gui = "bold" },
          b = { fg = "#ffffff", bg = "#1e1e2e" },
          c = { fg = "#cdd6f4", bg = "#11111b" },
        },
        insert = {
          a = { fg = "#000000", bg = "#ffb000", gui = "bold" },
        },
        visual = {
          a = { fg = "#000000", bg = "#89b4fa", gui = "bold" },
        },
        replace = {
          a = { fg = "#000000", bg = "#f38ba8", gui = "bold" },
        },
        command = {
          a = { fg = "#000000", bg = "#a6e22e", gui = "bold" },
        },
        inactive = {
          a = { fg = "#888888", bg = "#11111b", gui = "bold" },
          b = { fg = "#888888", bg = "#11111b" },
          c = { fg = "#888888", bg = "#11111b" },
        },
      }

      require("lualine").setup({
        options = {
          theme = mclaren_theme,
          globalstatus = true,
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },
}

