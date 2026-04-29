local map = vim.keymap.set

-- Salvar e sair
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Splits
map("n", "ss", "<cmd>split<cr>", { desc = "Split Horizontal" })
map("n", "sv", "<cmd>vsplit<cr>", { desc = "Split Vertical" })

-- Navegar entre splits
map("n", "sh", "<c-w>h", { desc = "Go Left" })
map("n", "sj", "<c-w>j", { desc = "Go Below" })
map("n", "sk", "<c-w>k", { desc = "Go Above" })
map("n", "sl", "<c-w>l", { desc = "Go Right" })

-- Redimensionar splits
map("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "Resize Left" })
map("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "Resize Right" })
map("n", "<M-k>", "<cmd>resize +2<cr>", { desc = "Resize Up" })
map("n", "<M-j>", "<cmd>resize -2<cr>", { desc = "Resize Down" })

-- Ctrl+j para sair do insert mode
map("i", "<C-j>", "<esc>", { desc = "Exit Insert Mode" })

-- LSP / Code actions (<leader>c)
map("n", "<leader>ck", vim.lsp.buf.hover, { desc = "Hover Info" })
map("n", "<leader>cg", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "<leader>cG", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "<leader>cI", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "<leader>cT", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
map("n", "<leader>cs", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run CodeLens" })
map("n", "<leader>ci", "<cmd>LspInfo<cr>", { desc = "LSP Info" })

map("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format" })
map("v", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format Selection" })
map("n", "<leader>cw", function()
  vim.lsp.buf.workspace_symbol("")
end, { desc = "Workspace Symbols" })

-- Go-to (g/G)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })

-- Diagnostics
map("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
