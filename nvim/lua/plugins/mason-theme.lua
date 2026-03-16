return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      }
      return opts
    end,
    config = function(_, opts)
      require("mason").setup(opts)

      vim.api.nvim_set_hl(0, "MasonNormal", { bg = "#0b0b0f" })
      vim.api.nvim_set_hl(0, "MasonHeader", { fg = "#000000", bg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlight", { fg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlightBlock", { fg = "#000000", bg = "#ff6a00", bold = true })
      vim.api.nvim_set_hl(0, "MasonHighlightBlockBold", { fg = "#000000", bg = "#ffb000", bold = true })
      vim.api.nvim_set_hl(0, "MasonMuted", { fg = "#8a8f98" })
      vim.api.nvim_set_hl(0, "MasonMutedBlock", { fg = "#cdd6f4", bg = "#1a1d26" })
      vim.api.nvim_set_hl(0, "MasonError", { fg = "#ff5f5f" })
    end,
  },
}
