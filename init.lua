-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.filetype.add({
  extension = {
    asm = "nasm",
  },
})

require("config.asm_info")
