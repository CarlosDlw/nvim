return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>t", desc = "Terminal" },
    },
    opts = {
      size = 20,
      direction = "float",
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
      open_mapping = false,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
      vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Exit Terminal Mode" })
    end,
  },
}
