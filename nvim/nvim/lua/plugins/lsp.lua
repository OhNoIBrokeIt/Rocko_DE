return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Per-server settings (overrides defaults below)
      local server_settings = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "bashls",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "ts_ls",
        },
        -- Replaced automatic_enable (0.11+ only) with explicit handlers
        -- Works on Neovim 0.10+
        handlers = {
          function(server_name)
            local config = server_settings[server_name] or {}
            config.capabilities = capabilities
            require("lspconfig")[server_name].setup(config)
          end,
        },
      })

      -- Diagnostic signs
      local signs = {
        Error = "󰅚 ",
        Warn  = "󰀪 ",
        Hint  = "󰌶 ",
        Info  = "󰋽 ",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,    opts)
          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,   opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,    opts)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,         opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,        opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,   opts)
          vim.keymap.set("n", "<leader>fd", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,  opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,  opts)
        end,
      })
    end,
  },
}
