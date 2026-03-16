return {
  {
    "catppuccin/nvim",
    opts = function(_, opts)
      opts.highlight_overrides = opts.highlight_overrides or {}
      opts.highlight_overrides.mocha = function(colors)
        return {
          -- Core UI
          NormalFloat = { bg = "#0b0b0f" },
          FloatBorder = { fg = "#ff6a00", bg = "#0b0b0f" },
          FloatTitle = { fg = "#000000", bg = "#ff6a00", bold = true },

          CursorLine = { bg = "#16161c" },
          Visual = { bg = "#2a1a10" },
          Search = { fg = "#000000", bg = "#ffb000", bold = true },
          IncSearch = { fg = "#000000", bg = "#ff6a00", bold = true },

          LineNr = { fg = "#5a5a66" },
          CursorLineNr = { fg = "#ffb000", bold = true },

          -- Diagnostics
          DiagnosticError = { fg = "#ff5f5f" },
          DiagnosticWarn = { fg = "#ffb000" },
          DiagnosticInfo = { fg = "#7dcfff" },
          DiagnosticHint = { fg = "#8bd5ca" },

          DiagnosticVirtualTextError = { fg = "#ff5f5f", bg = "#1a0f10" },
          DiagnosticVirtualTextWarn = { fg = "#ffb000", bg = "#1a1408" },
          DiagnosticVirtualTextInfo = { fg = "#7dcfff", bg = "#0d1820" },
          DiagnosticVirtualTextHint = { fg = "#8bd5ca", bg = "#0d1918" },

          DiagnosticUnderlineError = { undercurl = true, sp = "#ff5f5f" },
          DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffb000" },
          DiagnosticUnderlineInfo = { undercurl = true, sp = "#7dcfff" },
          DiagnosticUnderlineHint = { undercurl = true, sp = "#8bd5ca" },

          -- Signs
          DiagnosticSignError = { fg = "#ff5f5f", bg = "NONE" },
          DiagnosticSignWarn = { fg = "#ffb000", bg = "NONE" },
          DiagnosticSignInfo = { fg = "#7dcfff", bg = "NONE" },
          DiagnosticSignHint = { fg = "#8bd5ca", bg = "NONE" },

          -- Completion menu
          Pmenu = { fg = "#e5e5e5", bg = "#0f1117" },
          PmenuSel = { fg = "#000000", bg = "#ff6a00", bold = true },
          PmenuSbar = { bg = "#1a1c25" },
          PmenuThumb = { bg = "#ff6a00" },

          CmpItemAbbrMatch = { fg = "#ffb000", bold = true },
          CmpItemAbbrMatchFuzzy = { fg = "#ffb000", bold = true },
          CmpItemMenu = { fg = "#a0a0aa", italic = true },

          -- Telescope
          TelescopeNormal = { bg = "#0b0b0f" },
          TelescopeBorder = { fg = "#ff6a00", bg = "#0b0b0f" },
          TelescopeTitle = { fg = "#000000", bg = "#ff6a00", bold = true },
          TelescopePromptNormal = { bg = "#11131a" },
          TelescopePromptBorder = { fg = "#ffb000", bg = "#11131a" },
          TelescopePromptTitle = { fg = "#000000", bg = "#ffb000", bold = true },
          TelescopeResultsNormal = { bg = "#0b0b0f" },
          TelescopePreviewNormal = { bg = "#0b0b0f" },
          TelescopeSelection = { bg = "#1a1d26", bold = true },
          TelescopeSelectionCaret = { fg = "#ff6a00", bg = "#1a1d26" },

          -- NvimTree
          NvimTreeNormal = { bg = "NONE" },
          NvimTreeNormalFloat = { bg = "#0b0b0f" },
          NvimTreeCursorLine = { bg = "#16161c" },
          NvimTreeFolderIcon = { fg = "#ffb000" },
          NvimTreeOpenedFolderName = { fg = "#ff6a00", bold = true },

          -- GitSigns
          GitSignsAdd = { fg = "#a6e22e" },
          GitSignsChange = { fg = "#ffb000" },
          GitSignsDelete = { fg = "#ff5f5f" },

          -- Indent guides
          IblIndent = { fg = "#2b2f3a" },
          IblScope = { fg = "#ff6a00", bold = true },

          -- WhichKey
          WhichKey = { fg = "#ff6a00", bold = true },
          WhichKeyDesc = { fg = "#e5e5e5" },
          WhichKeyGroup = { fg = "#ffb000" },
          WhichKeySeparator = { fg = "#6c7086" },

          -- Harpoon / general
          Title = { fg = "#ff6a00", bold = true },
        }
      end
    end,
  },
}
