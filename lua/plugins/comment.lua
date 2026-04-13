return {
  {
    "numToStr/Comment.nvim",
    keys = {
      { "cd", function() require("Comment.api").toggle.linewise.current() end, desc = "Toggle Comment" },
      { "cd", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", mode = "v", desc = "Toggle Comment Block" },
    },
    opts = {
      mappings = false,
    },
  },
}
