return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      -- Find and grep include hidden files: dotfiles live under .config. .git is never wanted.
      vim.keymap.set("n", "<C-p>", function()
        builtin.find_files({ hidden = true, file_ignore_patterns = { "^%.git/" } })
      end, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", function()
        builtin.live_grep({ additional_args = { "--hidden", "--glob=!.git" } })
      end, { desc = "Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    end,
  },
  {
    -- Routes vim.ui.select (code actions, etc.) through Telescope.
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown({}) },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
