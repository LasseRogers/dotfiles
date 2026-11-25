return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      -- The built-in help can't be searched; the keymaps picker can, and <CR> runs the action.
      window = {
        mappings = {
          ["?"] = function()
            require("telescope.builtin").keymaps({ modes = { "n" }, only_buf = true })
          end,
          ["g?"] = "show_help",
        },
      },
      filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = true },
      },
    })
    vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle filesystem reveal left<CR>", { desc = "File tree" })
  end,
}
