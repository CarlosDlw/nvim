return {
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search Word" },
      { "<leader>sw", function() require("spectre").open_visual() end, mode = "v", desc = "Search Selection" },
      { "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search in File" },
    },
    opts = {
      highlight = {
        ui = "String",
        search = "DiffChange",
        replace = "DiffDelete",
      },
    },
  },
}
