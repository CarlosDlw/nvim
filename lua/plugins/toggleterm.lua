return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>t", desc = "Terminal" },
      { "<leader>tt", desc = "Terminal Toggle" },
      { "<leader>tr", desc = "Terminal Run" },
      { "<leader>ty", desc = "Terminal Tests" },
      { "<leader>tm", desc = "Terminal Misc" },
    },
    opts = {
      size = 20,
      direction = "float",
      start_in_insert = true,
      persist_mode = true,
      close_on_exit = true,
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
      local Terminal = require("toggleterm.terminal").Terminal
      local run_term = Terminal:new({
        id = 11,
        display_name = "run",
        hidden = true,
      })
      local test_term = Terminal:new({
        id = 12,
        display_name = "tests",
        hidden = true,
      })
      local misc_term = Terminal:new({
        id = 13,
        display_name = "misc",
        hidden = true,
      })

      vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
      vim.keymap.set("n", "<leader>tr", function()
        run_term:toggle()
      end, { desc = "Terminal Run" })
      vim.keymap.set("n", "<leader>ty", function()
        test_term:toggle()
      end, { desc = "Terminal Tests" })
      vim.keymap.set("n", "<leader>tm", function()
        misc_term:toggle()
      end, { desc = "Terminal Misc" })
      vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], { desc = "Exit Terminal Mode" })
    end,
  },
}
