local map = vim.keymap.set

local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "m", false)
end

local function surround_input(prompt)
  local value = vim.fn.input(prompt)
  vim.cmd.redraw()
  if value == nil or value == "" then
    return nil
  end
  return value
end

local function surround_add(char, linewise)
  local mode = vim.fn.mode()
  if mode:match("[vV\22]") then
    feedkeys((linewise and "gS" or "S") .. char)
    return
  end
  feedkeys((linewise and "yss" or "ysiw") .. char)
end

local function surround_change(linewise)
  local target = surround_input("Change surround target: ")
  if not target then
    return
  end
  local replacement = surround_input("Change surround replacement: ")
  if not replacement then
    return
  end
  feedkeys((linewise and "cS" or "cs") .. target .. replacement)
end

local function surround_delete()
  local target = surround_input("Delete surround: ")
  if not target then
    return
  end
  feedkeys("ds" .. target)
end

local function surround_delete_char(char)
  feedkeys("ds" .. char)
end

local function surround_add_prompt(linewise)
  local char = surround_input("Surround with: ")
  if not char then
    return
  end
  surround_add(char, linewise)
end

local function surround_change_to(target, replacement, linewise)
  feedkeys((linewise and "cS" or "cs") .. target .. replacement)
end

local function surround_change_prompt_target(replacement, linewise)
  local target = surround_input("Change surround target: ")
  if not target then
    return
  end
  surround_change_to(target, replacement, linewise)
end

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

-- Markers workflow
for i = 97, 122 do
  local c = string.char(i)

  -- set mark
  map("n", "mm" .. c, function()
    vim.cmd("mark " .. c)
  end, { desc = "Set Mark " .. c })

  -- goto full position (line + column)
  map("n", "mg" .. c, function()
    vim.cmd("normal! `" .. c)
  end, { desc = "Go to Mark " .. c })

  -- goto line only
  map("n", "ml" .. c, function()
    vim.cmd("normal! '" .. c)
  end, { desc = "Go to Mark Line " .. c })

  -- delete mark
  map("n", "mc" .. c, function()
    vim.cmd("delmarks " .. c)
  end, { desc = "Delete Mark " .. c })

  map("n", "mr" .. c, function()
    vim.cmd("delmarks " .. c)
  end, { desc = "Delete Mark " .. c })
end

--
map("n", "mra", function()
  vim.cmd("delmarks!")
end, { desc = "Delete All Marks" })

-- Around / Surround helpers (<leader>a)
map({ "n", "x" }, "<leader>aa", function()
  surround_add_prompt(false)
end, { desc = "Surround Prompt" })
map("n", "<leader>aA", function()
  surround_add_prompt(true)
end, { desc = "Surround Line Prompt" })
map("n", "<leader>ad", surround_delete, { desc = "Delete Surround" })
map("n", "<leader>ar", function()
  surround_change(false)
end, { desc = "Replace Surround" })
map("n", "<leader>aR", function()
  surround_change(true)
end, { desc = "Replace Surround Linewise" })
map({ "n", "x" }, "<leader>aq", function()
  surround_add('"', false)
end, { desc = "Surround Double Quotes" })
map({ "n", "x" }, "<leader>aQ", function()
  surround_add("'", false)
end, { desc = "Surround Single Quotes" })
map({ "n", "x" }, "<leader>ap", function()
  surround_add(")", false)
end, { desc = "Surround Parentheses" })
map({ "n", "x" }, "<leader>ab", function()
  surround_add("]", false)
end, { desc = "Surround Brackets" })
map({ "n", "x" }, "<leader>aB", function()
  surround_add("}", false)
end, { desc = "Surround Braces" })
map({ "n", "x" }, "<leader>al", function()
  surround_add(">", false)
end, { desc = "Surround Angle Brackets" })
map({ "n", "x" }, "<leader>ak", function()
  surround_add("`", false)
end, { desc = "Surround Backticks" })
map({ "n", "x" }, "<leader>at", function()
  surround_add("t", false)
end, { desc = "Surround Tag" })
map({ "n", "x" }, "<leader>af", function()
  surround_add("f", false)
end, { desc = "Surround Function Call" })
map({ "n", "x" }, "<leader>ai", function()
  surround_add("i", false)
end, { desc = "Surround Custom Delimiters" })
map("n", "<leader>axq", function()
  surround_delete_char("q")
end, { desc = "Delete Nearest Quote Surround" })
map("n", "<leader>axp", function()
  surround_delete_char(")")
end, { desc = "Delete Parentheses Surround" })
map("n", "<leader>axb", function()
  surround_delete_char("]")
end, { desc = "Delete Brackets Surround" })
map("n", "<leader>axB", function()
  surround_delete_char("}")
end, { desc = "Delete Braces Surround" })
map("n", "<leader>axl", function()
  surround_delete_char(">")
end, { desc = "Delete Angle Brackets Surround" })
map("n", "<leader>axt", function()
  surround_delete_char("t")
end, { desc = "Delete Tag Surround" })
map("n", "<leader>axf", function()
  surround_delete_char("f")
end, { desc = "Delete Function Call Surround" })
map("n", "<leader>acq", function()
  surround_change_to("q", '"', false)
end, { desc = "Change Quote Surround to Double Quotes" })
map("n", "<leader>acQ", function()
  surround_change_to("q", "'", false)
end, { desc = "Change Quote Surround to Single Quotes" })
map("n", "<leader>ack", function()
  surround_change_to("q", "`", false)
end, { desc = "Change Quote Surround to Backticks" })
map("n", "<leader>acp", function()
  surround_change_to("s", ")", false)
end, { desc = "Change Surround to Parentheses" })
map("n", "<leader>acb", function()
  surround_change_to("s", "]", false)
end, { desc = "Change Surround to Brackets" })
map("n", "<leader>acB", function()
  surround_change_to("s", "}", false)
end, { desc = "Change Surround to Braces" })
map("n", "<leader>acl", function()
  surround_change_to("s", ">", false)
end, { desc = "Change Surround to Angle Brackets" })
map("n", "<leader>act", function()
  surround_change_prompt_target("t", false)
end, { desc = "Change Surround to Tag" })
map("n", "<leader>acf", function()
  surround_change_prompt_target("f", false)
end, { desc = "Change Surround to Function Call" })
