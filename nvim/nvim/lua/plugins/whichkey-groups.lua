return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.spec = opts.spec or {}

      vim.list_extend(opts.spec, {
        { "<leader>f", group = "format/find" },
        { "<leader>h", group = "harpoon" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "trouble/lists" },
        { "<leader>s", group = "search/symbols" },
      })

      return opts
    end,
  },
}
