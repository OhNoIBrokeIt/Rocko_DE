return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "slant",
          diagnostics = "nvim_lsp",
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          indicator = {
            style = "icon",
            icon = "▎",
          },
        },
        highlights = {
          fill = {
            bg = "#0b0b0f",
          },
          background = {
            fg = "#7f849c",
            bg = "#11111b",
          },
          buffer_selected = {
            fg = "#ffffff",
            bg = "#16161c",
            bold = true,
            italic = false,
          },
          indicator_selected = {
            fg = "#ff6a00",
            bg = "#16161c",
          },
          separator = {
            fg = "#0b0b0f",
            bg = "#11111b",
          },
          separator_selected = {
            fg = "#0b0b0f",
            bg = "#16161c",
          },
          modified = {
            fg = "#ffb000",
            bg = "#11111b",
          },
          modified_selected = {
            fg = "#ffb000",
            bg = "#16161c",
          },
        },
      })
    end,
  },
}
