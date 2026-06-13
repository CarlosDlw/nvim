return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        asm_lsp = {},
      },
      setup = {
        asm_lsp = function(_, opts)
          local lspconfig = require("lspconfig")
          local configs = require("lspconfig.configs")

          if not configs.asm_lsp then
            configs.asm_lsp = {
              default_config = {
                cmd = { "asm-lsp" },
                filetypes = { "asm", "nasm", "s", "S" },
                root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
                settings = {},
              },
            }
          end

          lspconfig.asm_lsp.setup(opts)
          return true
        end,
      },
    },
  },
}
