return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        term_colors = true,
        integrations = {
          telescope = true,
          nvimtree = true,
          treesitter = true,
          noice = true,
          notify = true,
          dashboard = true,
          which_key = true,
        },
        color_overrides = {
          mocha = {
            rosewater = "#F5E0DC",
            flamingo = "#F2CDCD",
            pink = "#F5C2E7",
            mauve = "#CBA6F7",
            red = "#ff6a00",
            maroon = "#ff6a00",
            peach = "#ff6a00",
            yellow = "#ffb000",
            green = "#a6e22e",
            teal = "#94e2d5",
            sky = "#89dceb",
            sapphire = "#74c7ec",
            blue = "#89b4fa",
            lavender = "#b4befe",
          },
        },
      })

      vim.cmd.colorscheme("catppuccin")

      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
    end,
  },
}
