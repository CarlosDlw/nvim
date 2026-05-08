return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    init = function()
      local hl = vim.api.nvim_set_hl
      hl(0, "Normal", { bg = "none" })
      hl(0, "NormalNC", { bg = "none" })
      hl(0, "SignColumn", { bg = "none" })
      hl(0, "EndOfBuffer", { bg = "none" })
      hl(0, "NormalFloat", { bg = "none" })
      hl(0, "FloatBorder", { bg = "none" })
      hl(0, "Pmenu", { bg = "none" })
    end,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      integrations = {
        lsp_trouble = true,
        cmp = true,
        gitsigns = true,
        treesitter = true,
      },
      custom_highlights = function()
        return {
          Normal = { bg = "none" },
          NormalNC = { bg = "none" },
          SignColumn = { bg = "none" },
          EndOfBuffer = { bg = "none" },
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          Pmenu = { bg = "none" },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
