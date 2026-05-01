return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>fe", false },
    {
      "<leader>e",
      function()
        require("snacks").explorer()
      end,
      desc = "Explorer",
    },
  },
}
