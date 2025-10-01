return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      -- "yioneko/nvim-vtsls",
    },
    opts = {
      servers = {
        lua_ls = {},
        emmet_ls = {},
        vue_ls = {},
        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vim.fn.stdpath("data")
                        .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                    languages = { "vue" },
                    configNamespace = "typescript",
                    enableForWorkspaceTypeScriptVersions = true,
                  },
                },
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "mdx" },
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        tailwindcss = {},
        html = {},
        phpactor = {},
        eslint = { version = "13.1.2" },
        marksman = {},
      },
    },
    config = function(_, opts)
      require("mason").setup()
      local mason_lspconfig = require("mason-lspconfig")

      -- Setup mason-lspconfig with ensure_installed & auto-install
      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(opts.servers),
        automatic_installation = true,
      })

      for server, config in pairs(opts.servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function(_, opts)
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = { current_line = true },
      })
    end,
  },
}
