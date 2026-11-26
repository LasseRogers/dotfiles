-- Mason tools track the latest release: missing ones are installed and the rest updated in
-- the background, at most once a day. lazy-lock.json pins only the plugins.
return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- mason-lspconfig lets the list use lspconfig names for the servers.
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = {
      ensure_installed = {
        -- Language servers
        "lua_ls",
        "pyright",
        "ruff",
        "bashls",
        "dockerls",
        "docker_compose_language_service",
        "yamlls",
        "jsonls",
        "tsc", -- TypeScript 7 native language server (replaces ts_ls)
        "eslint",
        "rust_analyzer",
        "clangd",
        -- Formatters and linters
        "stylua",
        "shfmt",
        "shellcheck", -- picked up by bashls
        "hadolint",
        "sql-formatter",
        "prettier",
        "clang-format",
      },
      auto_update = true,
      debounce_hours = 24,
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      vim.lsp.config("rust_analyzer", {
        settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      -- Enables installed servers automatically; mason-tool-installer does the installing.
      require("mason-lspconfig").setup({
        -- Still installed from before the switch to tsc; would duplicate every diagnostic.
        automatic_enable = { exclude = { "ts_ls" } },
      })

      local map = vim.keymap.set
      map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      map("n", "<leader>gr", function() require("telescope.builtin").lsp_references() end, { desc = "References" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
      map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}
