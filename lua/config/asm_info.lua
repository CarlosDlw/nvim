local M = {}

local function get_telescope()
  if M._telescope then
    return M._telescope
  end

  local ok = pcall(require, "telescope")
  if not ok then
    return nil
  end

  local entry_display = require("telescope.pickers.entry_display")
  M._telescope = {
    pickers = require("telescope.pickers"),
    finders = require("telescope.finders"),
    previewers = require("telescope.previewers"),
    conf = require("telescope.config").values,
    actions = require("telescope.actions"),
    entry_display = entry_display,
    make_display = entry_display.create({
      separator = "  ",
      items = {
        { width = 20 },
        { width = 16 },
        { width = 32 },
        { remaining = true },
      },
    }),
  }

  return M._telescope
end

local function format_binary(value)
  local bin = ""
  for bit = 7, 0, -1 do
    local mask = 2 ^ bit
    if value >= mask then
      bin = bin .. "1"
      value = value - mask
    else
      bin = bin .. "0"
    end
  end
  return bin
end

local control_names = {
  [0] = "NUL",
  [1] = "SOH",
  [2] = "STX",
  [3] = "ETX",
  [4] = "EOT",
  [5] = "ENQ",
  [6] = "ACK",
  [7] = "BEL",
  [8] = "BS",
  [9] = "TAB",
  [10] = "LF",
  [11] = "VT",
  [12] = "FF",
  [13] = "CR",
  [14] = "SO",
  [15] = "SI",
  [16] = "DLE",
  [17] = "DC1",
  [18] = "DC2",
  [19] = "DC3",
  [20] = "DC4",
  [21] = "NAK",
  [22] = "SYN",
  [23] = "ETB",
  [24] = "CAN",
  [25] = "EM",
  [26] = "SUB",
  [27] = "ESC",
  [28] = "FS",
  [29] = "GS",
  [30] = "RS",
  [31] = "US",
  [127] = "DEL",
}

local control_descriptions = {
  [0] = "Null character / string terminator.",
  [1] = "Start of Header.",
  [2] = "Start of Text.",
  [3] = "End of Text.",
  [4] = "End of Transmission.",
  [5] = "Enquiry.",
  [6] = "Acknowledge.",
  [7] = "Bell / alert.",
  [8] = "Backspace.",
  [9] = "Horizontal tab.",
  [10] = "Line feed (newline).",
  [11] = "Vertical tab.",
  [12] = "Form feed.",
  [13] = "Carriage return.",
  [14] = "Shift Out.",
  [15] = "Shift In.",
  [16] = "Data Link Escape.",
  [17] = "Device Control 1.",
  [18] = "Device Control 2.",
  [19] = "Device Control 3.",
  [20] = "Device Control 4.",
  [21] = "Negative Acknowledge.",
  [22] = "Synchronous Idle.",
  [23] = "End of Transmission Block.",
  [24] = "Cancel.",
  [25] = "End of Medium.",
  [26] = "Substitute.",
  [27] = "Escape.",
  [28] = "File Separator.",
  [29] = "Group Separator.",
  [30] = "Record Separator.",
  [31] = "Unit Separator.",
  [127] = "Delete.",
}

local function is_printable_ascii(value)
  return value >= 32 and value <= 126
end

local function ascii_label(value)
  if value == 32 then
    return "SP"
  elseif control_names[value] then
    return control_names[value]
  end
  return string.char(value)
end

local function ascii_char(value)
  if value == 7 then
    return "\a"
  elseif value == 8 then
    return "\b"
  elseif value == 9 then
    return "\t"
  elseif value == 10 then
    return "\n"
  elseif value == 11 then
    return "\v"
  elseif value == 12 then
    return "\f"
  elseif value == 13 then
    return "\r"
  elseif is_printable_ascii(value) then
    return string.char(value)
  end
  return nil
end

local function trim(value)
  return value:match("^%s*(.-)%s*$") or ""
end

local function to_binary(value, bits)
  bits = bits or 8
  local masked = value % (2 ^ bits)
  local result = {}
  for i = bits - 1, 0, -1 do
    local mask = 2 ^ i
    result[#result + 1] = (masked >= mask) and "1" or "0"
    if masked >= mask then
      masked = masked - mask
    end
  end
  return table.concat(result)
end

local function format_signed(value, bits)
  local unsigned = value % (2 ^ bits)
  local msb = 2 ^ (bits - 1)
  if unsigned >= msb then
    return unsigned - 2 ^ bits
  end
  return unsigned
end

local function byte_list_from_string(text)
  local bytes = {}
  for i = 1, #text do
    bytes[#bytes + 1] = string.byte(text, i)
  end
  return bytes
end

local function parse_number_input(text)
  local normalized = trim(text)
  if normalized == "" then
    return nil
  end

  local sign = 1
  if normalized:sub(1, 1) == "+" then
    normalized = normalized:sub(2)
  elseif normalized:sub(1, 1) == "-" then
    sign = -1
    normalized = normalized:sub(2)
  end

  if normalized:match("^0[xX][0-9a-fA-F]+$") then
    return tonumber(normalized, 16) * sign, "hex"
  elseif normalized:match("^0[bB][01]+$") then
    return tonumber(normalized:sub(3), 2) * sign, "binary"
  elseif normalized:match("^0[oO]?[0-7]+$") and normalized:sub(1, 2) ~= "0x" then
    return tonumber(normalized, 8) * sign, "octal"
  elseif normalized:match("^[01]+$") and #normalized > 1 then
    return tonumber(normalized, 2) * sign, "binary"
  elseif normalized:match("^%d+$") then
    return tonumber(normalized, 10) * sign, "decimal"
  end

  return nil
end

local function codepoints_from_text(text)
  local values = {}
  for _, code in utf8.codes(text) do
    values[#values + 1] = code
  end
  return values
end

local function make_conversion_lines(raw_input)
  local input = trim(raw_input)
  if input == "" then
    return {
      "Type a number (decimal, 0xhex, 0bbin, 0octal) or text on the prompt.",
      "Conversions will appear here as you type.",
    }
  end

  local lines = {}
  lines[#lines + 1] = "Input: " .. input
  lines[#lines + 1] = ""

  local number_value, inferred_type = parse_number_input(input)
  if number_value then
    lines[#lines + 1] = "Detected type: " .. inferred_type .. " number"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Unsigned 8-bit : "
      .. tostring(number_value % 256)
      .. " / "
      .. string.format("0x%02X", number_value % 256)
      .. " / "
      .. string.format("%03o", number_value % 256)
      .. " / "
      .. to_binary(number_value, 8)
    lines[#lines + 1] = "Signed 8-bit   : " .. tostring(format_signed(number_value, 8))
    lines[#lines + 1] = "Unsigned 16-bit: "
      .. tostring(number_value % 65536)
      .. " / "
      .. string.format("0x%04X", number_value % 65536)
      .. " / "
      .. string.format("%06o", number_value % 65536)
      .. " / "
      .. to_binary(number_value, 16)
    lines[#lines + 1] = "Signed 16-bit  : " .. tostring(format_signed(number_value, 16))
    lines[#lines + 1] = "Unsigned 32-bit: "
      .. tostring(number_value % 2 ^ 32)
      .. " / "
      .. string.format("0x%08X", number_value % 2 ^ 32)
      .. " / "
      .. string.format("%011o", number_value % 2 ^ 32)
      .. " / "
      .. to_binary(number_value, 32)
    lines[#lines + 1] = "Signed 32-bit  : " .. tostring(format_signed(number_value, 32))
    lines[#lines + 1] = "Unsigned 64-bit: "
      .. tostring(number_value % 2 ^ 64)
      .. " / "
      .. string.format("0x%016X", number_value % 2 ^ 64)
      .. " / "
      .. string.format("%021o", number_value % 2 ^ 64)
    lines[#lines + 1] = "Signed 64-bit  : " .. tostring(format_signed(number_value, 64))
    if number_value >= 0 and number_value <= 255 then
      local char = ascii_char(number_value)
      if char then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "ASCII char: " .. tostring(char) .. "  (" .. ascii_label(number_value) .. ")"
      else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "ASCII char: non-printable / " .. ascii_label(number_value)
      end
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Raw formats:"
    lines[#lines + 1] = "  decimal: " .. tostring(number_value)
    lines[#lines + 1] = "  hex    : " .. string.format("0x%X", number_value)
    lines[#lines + 1] = "  octal  : " .. string.format("0o%o", number_value)
    lines[#lines + 1] = "  binary : " .. to_binary(number_value, math.max(8, #tostring(input) * 4))
  else
    lines[#lines + 1] = "Detected type: text / bytes"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Length: " .. #input .. " chars"
    local bytes = byte_list_from_string(input)
    if #bytes > 0 then
      local ascii_chars = {}
      local hex_values = {}
      local oct_values = {}
      local bin_values = {}
      local codepoints = codepoints_from_text(input)
      for i, b in ipairs(bytes) do
        ascii_chars[#ascii_chars + 1] = (is_printable_ascii(b) and string.char(b)) or "."
        hex_values[#hex_values + 1] = string.format("0x%02X", b)
        oct_values[#oct_values + 1] = string.format("0%03o", b)
        bin_values[#bin_values + 1] = to_binary(b, 8)
      end
      lines[#lines + 1] = ""
      lines[#lines + 1] = "Bytes: " .. table.concat(bytes, ", ")
      lines[#lines + 1] = "Hex  : " .. table.concat(hex_values, " ")
      lines[#lines + 1] = "Oct  : " .. table.concat(oct_values, " ")
      lines[#lines + 1] = "Bin  : " .. table.concat(bin_values, " ")
      lines[#lines + 1] = "Text : " .. table.concat(ascii_chars)
      lines[#lines + 1] = "UTF-8 codepoints: " .. table.concat(codepoints, ", ")
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Press q or <Esc> to close."
  return lines
end

local function open_do_window()
  local api = vim.api

  local width = math.max(40, math.floor(vim.o.columns * 0.6))
  local height = math.max(8, math.floor(vim.o.lines * 0.5))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- prompt buffer/window (single-line editable)
  local prompt_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(prompt_buf, "buftype", "prompt")
  api.nvim_buf_set_option(prompt_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(prompt_buf, "filetype", "asm_info")
  api.nvim_buf_set_option(prompt_buf, "modifiable", true)
  api.nvim_buf_set_option(prompt_buf, "swapfile", false)

  local prompt_win = api.nvim_open_win(prompt_buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = 1,
    style = "minimal",
    border = "rounded",
  })
  -- set prompt and enter insert mode
  vim.fn.prompt_setprompt(prompt_buf, "")
  api.nvim_win_set_cursor(prompt_win, { 1, 9 })
  vim.cmd("startinsert!")

  -- preview buffer/window (read-only)
  local preview_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(preview_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(preview_buf, "filetype", "asm_info")
  api.nvim_buf_set_option(preview_buf, "modifiable", false)

  local preview_h = math.max(3, height - 2)
  local preview_win = api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    row = row + 2,
    col = col,
    width = width,
    height = preview_h,
    style = "minimal",
    border = "rounded",
  })

  -- autocmd group
  local aug = api.nvim_create_augroup("AsmConvert", { clear = true })

  local function update()
    if not api.nvim_buf_is_valid(preview_buf) or not api.nvim_buf_is_valid(prompt_buf) then
      return
    end
    local prompt_line = api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1] or ""
    local input = trim(prompt_line:gsub("^Convert> ", ""))
    local lines = make_conversion_lines(input)
    api.nvim_buf_set_option(preview_buf, "modifiable", true)
    api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
    api.nvim_buf_set_option(preview_buf, "modifiable", false)
  end

  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = aug,
    buffer = prompt_buf,
    callback = function()
      pcall(update)
    end,
  })

  -- initial update and manual refresh mapping
  pcall(update)
  vim.keymap.set("i", "<C-l>", function()
    pcall(update)
  end, { buffer = prompt_buf, noremap = true, silent = true })

  -- close mappings
  vim.keymap.set("i", "<esc>", function()
    pcall(api.nvim_win_close, preview_win, true)
    pcall(api.nvim_win_close, prompt_win, true)
  end, { buffer = prompt_buf, noremap = true, silent = true })
end

local function make_preview(item)
  local lines = {}
  if item.title then
    table.insert(lines, item.title)
    table.insert(lines, string.rep("-", #item.title))
  end
  if item.label then
    table.insert(lines, "Label: " .. item.label)
  end
  if item.code then
    table.insert(lines, "Code : " .. item.code)
  end
  if item.decimal then
    table.insert(lines, "Dec  : " .. item.decimal)
  end
  if item.octal then
    table.insert(lines, "Oct  : " .. item.octal)
  end
  if item.binary then
    table.insert(lines, "Bin  : " .. item.binary)
  end
  if item.hex then
    table.insert(lines, "Hex  : " .. item.hex)
  end
  if item.int80_decimal or item.int80_hex or item.int80_octal then
    table.insert(lines, "")
    table.insert(lines, "Legacy (int 0x80):")
    if item.int80_decimal then
      table.insert(lines, "  Dec  : " .. item.int80_decimal)
    end
    if item.int80_hex then
      table.insert(lines, "  Hex  : " .. item.int80_hex)
    end
    if item.int80_octal then
      table.insert(lines, "  Oct  : " .. item.int80_octal)
    end
  end
  if item.char then
    table.insert(lines, "Char : " .. item.char)
  end
  if item.extra then
    table.insert(lines, "")
    table.insert(lines, item.extra)
  end
  if item.description then
    table.insert(lines, "")
    table.insert(lines, item.description)
  end
  return lines
end

local function make_ascii_entries()
  local items = {}
  for value = 0, 127 do
    local code = string.format("0x%02X", value)
    local octal = string.format("0%03o", value)
    local binary = format_binary(value)
    local label = ascii_label(value)
    local char = ascii_char(value)
    local description = control_descriptions[value]
      or (is_printable_ascii(value) and ("Printable ASCII character '" .. char .. "'."))
      or "Control character."

    items[#items + 1] = {
      label = label,
      code = code,
      decimal = tostring(value),
      octal = octal,
      binary = binary,
      char = char,
      description = description,
    }
  end
  return items
end

local function make_hex_entries()
  local items = {}
  for value = 0, 255 do
    local code = string.format("0x%02X", value)
    local octal = string.format("0%03o", value)
    local binary = format_binary(value)
    local char = is_printable_ascii(value) and string.char(value) or nil
    local description = char and ("Printable ASCII character '" .. char .. "'.") or "Byte value."

    items[#items + 1] = {
      label = code,
      code = code,
      decimal = tostring(value),
      octal = octal,
      binary = binary,
      char = char,
      description = description,
    }
  end
  return items
end

local function make_octal_entries()
  local items = {}
  for value = 0, 255 do
    local code = string.format("0%03o", value)
    local hex = string.format("0x%02X", value)
    local decimal = tostring(value)
    local char = is_printable_ascii(value) and string.char(value) or nil
    local description = char and ("Printable ASCII character '" .. char .. "'.") or "Byte value in octal."

    items[#items + 1] = {
      label = code,
      code = code,
      decimal = decimal,
      hex = hex,
      binary = format_binary(value),
      char = char,
      description = description,
    }
  end
  return items
end

local function make_binary_entries()
  local items = {}
  for value = 0, 255 do
    local code = format_binary(value)
    local hex = string.format("0x%02X", value)
    local decimal = tostring(value)
    local octal = string.format("0%03o", value)
    local char = is_printable_ascii(value) and string.char(value) or nil
    local description = char and ("Printable ASCII character '" .. char .. "'.") or "Byte value in binary."

    items[#items + 1] = {
      label = code,
      code = code,
      decimal = decimal,
      octal = octal,
      hex = hex,
      char = char,
      description = description,
    }
  end
  return items
end

local entries = {
  constants = {
    title = "Common NASM / x86_64 assembly constants",
    items = {
      {
        label = "LF",
        code = "0x0A",
        decimal = "10",
        octal = "012",
        char = "\n",
        extra = "Line feed / newline.",
        description = "Common control character for line breaks.",
      },
      {
        label = "CR",
        code = "0x0D",
        decimal = "13",
        octal = "015",
        char = "\r",
        extra = "Carriage return.",
        description = "Used together with LF in DOS/Windows text files.",
      },
      {
        label = "TAB",
        code = "0x09",
        decimal = "9",
        octal = "011",
        char = "\t",
        description = "Horizontal tab character.",
      },
      {
        label = "NUL",
        code = "0x00",
        decimal = "0",
        octal = "000",
        char = "\0",
        description = "Null byte used for string termination or padding.",
      },
      {
        label = "SPACE",
        code = "0x20",
        decimal = "32",
        octal = "040",
        char = " ",
        description = "ASCII space character.",
      },
      {
        label = "SYS_CALL",
        code = "0x80",
        decimal = "128",
        octal = "0200",
        description = "Legacy Linux interrupt vector for syscalls.",
      },
      {
        label = "SYS_EXIT",
        code = "0x01",
        decimal = "1",
        description = "Linux syscall number for exit (x86 int 0x80 ABI).",
      },
      {
        label = "SYS_READ",
        code = "0x03",
        decimal = "3",
        description = "Linux syscall number for read (x86 int 0x80 ABI).",
      },
      {
        label = "SYS_WRITE",
        code = "0x04",
        decimal = "4",
        description = "Linux syscall number for write (x86 int 0x80 ABI).",
      },
      {
        label = "STD_IN",
        code = "0x00",
        decimal = "0",
        octal = "000",
        description = "Standard input file descriptor.",
      },
      {
        label = "STD_OUT",
        code = "0x01",
        decimal = "1",
        octal = "001",
        description = "Standard output file descriptor.",
      },
      {
        label = "STD_ERR",
        code = "0x02",
        decimal = "2",
        octal = "002",
        description = "Standard error file descriptor.",
      },
      { label = "TRUE", code = "0x01", decimal = "1", description = "Boolean true in assembler conventions." },
      { label = "FALSE", code = "0x00", decimal = "0", description = "Boolean false in assembler conventions." },
      {
        label = "PAGE_SIZE",
        code = "0x1000",
        decimal = "4096",
        description = "Common memory page size on x86_64 Linux.",
      },
      { label = "MAX_BYTE", code = "0xFF", decimal = "255", description = "Maximum unsigned value in a single byte." },
      {
        label = "MAX_WORD",
        code = "0xFFFF",
        decimal = "65535",
        description = "Maximum unsigned value in a 16-bit word.",
      },
    },
  },
  ascii = {
    title = "ASCII reference table (0x00-0x7F)",
    items = make_ascii_entries(),
  },
  hex = {
    title = "Hexadecimal values (0x00-0xFF)",
    items = make_hex_entries(),
  },
  octal = {
    title = "Octal values (0o000-0o377)",
    items = make_octal_entries(),
  },
  binary = {
    title = "Binary values (8-bit)",
    items = make_binary_entries(),
  },
  directives = {
    title = "NASM directives and segments",
    items = {
      { label = "section .text", code = "section .text", description = "Defines the program code segment." },
      { label = "section .data", code = "section .data", description = "Defines the writable static data segment." },
      { label = "section .bss", code = "section .bss", description = "Defines uninitialized data." },
      { label = "global", code = "global <symbol>", description = "Exports a symbol for the linker." },
      {
        label = "extern",
        code = "extern <symbol>",
        description = "Declares an external symbol from another object file.",
      },
      { label = "bits", code = "bits 64", description = "Sets the assembler mode to 64-bit." },
      { label = "align", code = "align 16", description = "Aligns the next data or code to a boundary." },
      { label = "equ", code = "NAME equ VALUE", description = "Defines a constant symbol." },
      { label = "org", code = "org 0x100", description = "Sets the origin address for assembled output." },
      { label = "times", code = "times 16 db 0", description = "Repeats a directive or data definition." },
      { label = "db", code = "db 0x41", description = "Define byte(s) of initialized data." },
      { label = "dw", code = "dw 0x1234", description = "Define word (16-bit) data." },
      { label = "dd", code = "dd 0x12345678", description = "Define doubleword (32-bit) data." },
      { label = "dq", code = "dq 0x1234567890ABCDEF", description = "Define quadword (64-bit) data." },
      { label = "resb", code = "resb 8", description = "Reserve bytes without initialization." },
      { label = "resw", code = "resw 4", description = "Reserve words without initialization." },
      { label = "resd", code = "resd 2", description = "Reserve doublewords without initialization." },
      { label = "resq", code = "resq 1", description = "Reserve quadwords without initialization." },
    },
  },
  registers = {
    title = "x86_64 registers reference",
    items = {
      {
        label = "rax / eax",
        code = "rax / eax",
        description = "Accumulator register; 64-bit and 32-bit aliases. Used for syscall numbers / return values.",
      },
      {
        label = "rdi / edi",
        code = "rdi / edi",
        description = "Destination index register; 1st syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "rsi / esi",
        code = "rsi / esi",
        description = "Source index register; 2nd syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "rdx / edx",
        code = "rdx / edx",
        description = "Data register; 3rd syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "r10 / r10d",
        code = "r10 / r10d",
        description = "Temp register, caller-saved. 64-bit and 32-bit aliases.",
      },
      {
        label = "r8 / r8d",
        code = "r8 / r8d",
        description = "General-purpose register; 5th syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "r9 / r9d",
        code = "r9 / r9d",
        description = "General-purpose register; 6th syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "rcx / ecx",
        code = "rcx / ecx",
        description = "Counter register; 4th syscall argument in x86_64. 64-bit and 32-bit aliases.",
      },
      {
        label = "r11 / r11d",
        code = "r11 / r11d",
        description = "Temp register, caller-saved. 64-bit and 32-bit aliases.",
      },
      {
        label = "rbx / ebx",
        code = "rbx / ebx",
        description = "Base register, callee-saved. 64-bit and 32-bit aliases.",
      },
      {
        label = "rsp / esp",
        code = "rsp / esp",
        description = "Stack pointer, points to the top of the stack. 64-bit and 32-bit aliases.",
      },
      {
        label = "rbp / ebp",
        code = "rbp / ebp",
        description = "Base pointer for frame references. 64-bit and 32-bit aliases.",
      },
      { label = "r12 / r12d", code = "r12 / r12d", description = "Callee-saved register. 64-bit and 32-bit aliases." },
      { label = "r13 / r13d", code = "r13 / r13d", description = "Callee-saved register. 64-bit and 32-bit aliases." },
      { label = "r14 / r14d", code = "r14 / r14d", description = "Callee-saved register. 64-bit and 32-bit aliases." },
      { label = "r15 / r15d", code = "r15 / r15d", description = "Callee-saved register. 64-bit and 32-bit aliases." },
      {
        label = "rip",
        code = "rip",
        description = "Instruction pointer for RIP-relative addressing. No 32-bit alias.",
      },
    },
  },
  instructions = {
    title = "Common x86_64 instructions",
    items = {
      { label = "mov", code = "mov dst, src", description = "Move data from source to destination." },
      { label = "movzx", code = "movzx dst, src", description = "Move with zero-extension." },
      { label = "movsx", code = "movsx dst, src", description = "Move with sign-extension." },
      { label = "lea", code = "lea reg, [address]", description = "Load effective address into a register." },
      { label = "add", code = "add dst, src", description = "Add source to destination." },
      { label = "sub", code = "sub dst, src", description = "Subtract source from destination." },
      { label = "inc", code = "inc dst", description = "Increment destination by one." },
      { label = "dec", code = "dec dst", description = "Decrement destination by one." },
      { label = "imul", code = "imul dst, src", description = "Signed multiply." },
      { label = "mul", code = "mul src", description = "Unsigned multiply." },
      { label = "div", code = "div src", description = "Unsigned divide." },
      { label = "idiv", code = "idiv src", description = "Signed divide." },
      { label = "xor", code = "xor dst, src", description = "Bitwise exclusive OR; common zero idiom." },
      { label = "or", code = "or dst, src", description = "Bitwise OR." },
      { label = "and", code = "and dst, src", description = "Bitwise AND." },
      { label = "not", code = "not dst", description = "Bitwise NOT." },
      { label = "sal", code = "sal dst, count", description = "Arithmetic left shift (same as shl)." },
      { label = "shr", code = "shr dst, count", description = "Logical right shift." },
      { label = "sar", code = "sar dst, count", description = "Arithmetic right shift." },
      { label = "rol", code = "rol dst, count", description = "Rotate left." },
      { label = "ror", code = "ror dst, count", description = "Rotate right." },
      { label = "cmp", code = "cmp lhs, rhs", description = "Compare values and update status flags." },
      {
        label = "test",
        code = "test lhs, rhs",
        description = "Bitwise AND and update flags without modifying operands.",
      },
      { label = "jmp", code = "jmp label", description = "Unconditional jump." },
      { label = "je", code = "je label", description = "Jump if equal / zero flag set." },
      { label = "jne", code = "jne label", description = "Jump if not equal / zero flag clear." },
      { label = "jl", code = "jl label", description = "Jump if less (signed)." },
      { label = "jle", code = "jle label", description = "Jump if less or equal (signed)." },
      { label = "jg", code = "jg label", description = "Jump if greater (signed)." },
      { label = "jge", code = "jge label", description = "Jump if greater or equal (signed)." },
      { label = "ja", code = "ja label", description = "Jump if above / carry flag clear and zero flag clear." },
      { label = "jb", code = "jb label", description = "Jump if below / carry flag set." },
      { label = "call", code = "call label", description = "Call a procedure and push return address." },
      { label = "ret", code = "ret", description = "Return from procedure." },
      { label = "push", code = "push src", description = "Push a value onto the stack." },
      { label = "pop", code = "pop dst", description = "Pop a value from the stack." },
      { label = "syscall", code = "syscall", description = "Make a system call on x86_64." },
      { label = "int", code = "int 0x80", description = "Software interrupt, legacy syscall interface." },
      { label = "nop", code = "nop", description = "No operation instruction." },
    },
  },
  syscalls = {
    title = "Common x86_64 Linux syscall numbers",
    items = {
      {
        label = "SYS_READ",
        code = "0",
        decimal = "0",
        hex = "0x00",
        octal = "000",
        description = "Read from a file descriptor.",
      },
      {
        label = "SYS_WRITE",
        code = "1",
        decimal = "1",
        hex = "0x01",
        octal = "001",
        description = "Write to a file descriptor.",
      },
      { label = "SYS_OPEN", code = "2", decimal = "2", hex = "0x02", octal = "002", description = "Open a file." },
      {
        label = "SYS_CLOSE",
        code = "3",
        decimal = "3",
        hex = "0x03",
        octal = "003",
        description = "Close a file descriptor.",
      },
      { label = "SYS_STAT", code = "4", decimal = "4", hex = "0x04", octal = "004", description = "Get file status." },
      {
        label = "SYS_FSTAT",
        code = "5",
        decimal = "5",
        hex = "0x05",
        octal = "005",
        description = "Get file status for an open file.",
      },
      {
        label = "SYS_LSTAT",
        code = "6",
        decimal = "6",
        hex = "0x06",
        octal = "006",
        description = "Get file status for a pathname.",
      },
      {
        label = "SYS_POLL",
        code = "7",
        decimal = "7",
        hex = "0x07",
        octal = "007",
        description = "Wait for events on file descriptors.",
      },
      {
        label = "SYS_LSEEK",
        code = "8",
        decimal = "8",
        hex = "0x08",
        octal = "010",
        description = "Reposition file offset.",
      },
      {
        label = "SYS_MMAP",
        code = "9",
        decimal = "9",
        hex = "0x09",
        octal = "011",
        description = "Create memory mapping.",
      },
      {
        label = "SYS_MPROTECT",
        code = "10",
        decimal = "10",
        hex = "0x0A",
        octal = "012",
        description = "Set protection on a memory region.",
      },
      {
        label = "SYS_MUNMAP",
        code = "11",
        decimal = "11",
        hex = "0x0B",
        octal = "013",
        description = "Remove a memory mapping.",
      },
      {
        label = "SYS_BRK",
        code = "12",
        decimal = "12",
        hex = "0x0C",
        octal = "014",
        description = "Change data segment size.",
      },
      {
        label = "SYS_RT_SIGACTION",
        code = "13",
        decimal = "13",
        hex = "0x0D",
        octal = "015",
        description = "Examine or change a signal action.",
      },
      {
        label = "SYS_RT_SIGPROCMASK",
        code = "14",
        decimal = "14",
        hex = "0x0E",
        octal = "016",
        description = "Examine or change blocked signals.",
      },
      {
        label = "SYS_RT_SIGRETURN",
        code = "15",
        decimal = "15",
        hex = "0x0F",
        octal = "017",
        description = "Return from a signal handler.",
      },
      {
        label = "SYS_IOCTL",
        code = "16",
        decimal = "16",
        hex = "0x10",
        octal = "020",
        description = "Control device I/O.",
      },
      {
        label = "SYS_PREAD64",
        code = "17",
        decimal = "17",
        hex = "0x11",
        octal = "021",
        description = "Read from a file descriptor at a position.",
      },
      {
        label = "SYS_PWRITE64",
        code = "18",
        decimal = "18",
        hex = "0x12",
        octal = "022",
        description = "Write to a file descriptor at a position.",
      },
      {
        label = "SYS_READV",
        code = "19",
        decimal = "19",
        hex = "0x13",
        octal = "023",
        description = "Read data into multiple buffers.",
      },
      {
        label = "SYS_WRITEV",
        code = "20",
        decimal = "20",
        hex = "0x14",
        octal = "024",
        description = "Write data from multiple buffers.",
      },
      {
        label = "SYS_ACCESS",
        code = "21",
        decimal = "21",
        hex = "0x15",
        octal = "025",
        description = "Check user's permissions for a file.",
      },
      { label = "SYS_PIPE", code = "22", decimal = "22", hex = "0x16", octal = "026", description = "Create a pipe." },
      {
        label = "SYS_SELECT",
        code = "23",
        decimal = "23",
        hex = "0x17",
        octal = "027",
        description = "Wait for I/O readiness.",
      },
      {
        label = "SYS_SCHED_YIELD",
        code = "24",
        decimal = "24",
        hex = "0x18",
        octal = "030",
        description = "Yield the processor.",
      },
      {
        label = "SYS_MREMAP",
        code = "25",
        decimal = "25",
        hex = "0x19",
        octal = "031",
        description = "Remap a virtual memory address.",
      },
      {
        label = "SYS_MSYNC",
        code = "26",
        decimal = "26",
        hex = "0x1A",
        octal = "032",
        description = "Synchronize a mapped memory region.",
      },
      {
        label = "SYS_MINCORE",
        code = "27",
        decimal = "27",
        hex = "0x1B",
        octal = "033",
        description = "Determine memory residency.",
      },
      {
        label = "SYS_MADVISE",
        code = "28",
        decimal = "28",
        hex = "0x1C",
        octal = "034",
        description = "Give advice about memory usage.",
      },
      {
        label = "SYS_SHMGET",
        code = "29",
        decimal = "29",
        hex = "0x1D",
        octal = "035",
        description = "Get shared memory segment identifier.",
      },
      {
        label = "SYS_SHMAT",
        code = "30",
        decimal = "30",
        hex = "0x1E",
        octal = "036",
        description = "Attach a shared memory segment.",
      },
      {
        label = "SYS_SHMCTL",
        code = "31",
        decimal = "31",
        hex = "0x1F",
        octal = "037",
        description = "Control a shared memory segment.",
      },
      {
        label = "SYS_DUP",
        code = "32",
        decimal = "32",
        hex = "0x20",
        octal = "040",
        description = "Duplicate a file descriptor.",
      },
      {
        label = "SYS_DUP2",
        code = "33",
        decimal = "33",
        hex = "0x21",
        octal = "041",
        description = "Duplicate a file descriptor to a given value.",
      },
      {
        label = "SYS_NANOSLEEP",
        code = "35",
        decimal = "35",
        hex = "0x23",
        octal = "043",
        description = "Suspend execution for nanoseconds.",
      },
      {
        label = "SYS_GETPID",
        code = "39",
        decimal = "39",
        hex = "0x27",
        octal = "047",
        description = "Get process ID.",
      },
      {
        label = "SYS_SOCKET",
        code = "41",
        decimal = "41",
        hex = "0x29",
        octal = "051",
        description = "Create a communication endpoint.",
      },
      {
        label = "SYS_CONNECT",
        code = "42",
        decimal = "42",
        hex = "0x2A",
        octal = "052",
        description = "Initiate a socket connection.",
      },
      {
        label = "SYS_ACCEPT",
        code = "43",
        decimal = "43",
        hex = "0x2B",
        octal = "053",
        description = "Accept a connection on a socket.",
      },
      {
        label = "SYS_SENDTO",
        code = "44",
        decimal = "44",
        hex = "0x2C",
        octal = "054",
        description = "Send a message on a socket.",
      },
      {
        label = "SYS_RECVFROM",
        code = "45",
        decimal = "45",
        hex = "0x2D",
        octal = "055",
        description = "Receive a message from a socket.",
      },
      {
        label = "SYS_SENDMSG",
        code = "46",
        decimal = "46",
        hex = "0x2E",
        octal = "056",
        description = "Send a message using scatter/gather I/O.",
      },
      {
        label = "SYS_RECVMSG",
        code = "47",
        decimal = "47",
        hex = "0x2F",
        octal = "057",
        description = "Receive a message using scatter/gather I/O.",
      },
      {
        label = "SYS_SHUTDOWN",
        code = "48",
        decimal = "48",
        hex = "0x30",
        octal = "060",
        description = "Shut down part of a connection.",
      },
      {
        label = "SYS_BIND",
        code = "49",
        decimal = "49",
        hex = "0x31",
        octal = "061",
        description = "Bind a socket to a local address.",
      },
      {
        label = "SYS_LISTEN",
        code = "50",
        decimal = "50",
        hex = "0x32",
        octal = "062",
        description = "Listen for socket connections.",
      },
      {
        label = "SYS_CLONE",
        code = "56",
        decimal = "56",
        hex = "0x38",
        octal = "070",
        description = "Create a child process.",
      },
      {
        label = "SYS_FORK",
        code = "57",
        decimal = "57",
        hex = "0x39",
        octal = "071",
        description = "Create a child process.",
      },
      {
        label = "SYS_VFORK",
        code = "58",
        decimal = "58",
        hex = "0x3A",
        octal = "072",
        description = "Create a child process without copying page tables.",
      },
      {
        label = "SYS_EXECVE",
        code = "59",
        decimal = "59",
        hex = "0x3B",
        octal = "073",
        description = "Execute a program.",
      },
      {
        label = "SYS_EXIT",
        code = "60",
        decimal = "60",
        hex = "0x3C",
        octal = "074",
        description = "Exit the calling process.",
      },
      {
        label = "SYS_WAIT4",
        code = "61",
        decimal = "61",
        hex = "0x3D",
        octal = "075",
        description = "Wait for process state changes.",
      },
      {
        label = "SYS_KILL",
        code = "62",
        decimal = "62",
        hex = "0x3E",
        octal = "076",
        description = "Send a signal to a process.",
      },
      {
        label = "SYS_UNAME",
        code = "63",
        decimal = "63",
        hex = "0x3F",
        octal = "077",
        description = "Get system information.",
      },
      {
        label = "SYS_CHDIR",
        code = "80",
        decimal = "80",
        hex = "0x50",
        octal = "120",
        description = "Change the current working directory.",
      },
      {
        label = "SYS_FCHDIR",
        code = "81",
        decimal = "81",
        hex = "0x51",
        octal = "121",
        description = "Change working directory using a file descriptor.",
      },
      {
        label = "SYS_CHMOD",
        code = "90",
        decimal = "90",
        hex = "0x5A",
        octal = "132",
        description = "Change file mode bits.",
      },
      {
        label = "SYS_CHOWN",
        code = "92",
        decimal = "92",
        hex = "0x5C",
        octal = "134",
        description = "Change file owner and group.",
      },
      {
        label = "SYS_GETUID",
        code = "102",
        decimal = "102",
        hex = "0x66",
        octal = "146",
        description = "Get user ID.",
      },
      {
        label = "SYS_GETGID",
        code = "104",
        decimal = "104",
        hex = "0x68",
        octal = "150",
        description = "Get group ID.",
      },
      {
        label = "SYS_SETUID",
        code = "105",
        decimal = "105",
        hex = "0x69",
        octal = "151",
        description = "Set user ID.",
      },
      {
        label = "SYS_SETGID",
        code = "106",
        decimal = "106",
        hex = "0x6A",
        octal = "152",
        description = "Set group ID.",
      },
      {
        label = "SYS_GETEUID",
        code = "107",
        decimal = "107",
        hex = "0x6B",
        octal = "153",
        description = "Get effective user ID.",
      },
      {
        label = "SYS_GETEGID",
        code = "108",
        decimal = "108",
        hex = "0x6C",
        octal = "154",
        description = "Get effective group ID.",
      },
      {
        label = "SYS_ARCH_PRCTL",
        code = "158",
        decimal = "158",
        hex = "0x9E",
        octal = "236",
        description = "Set or get architecture-specific thread state.",
      },
      {
        label = "SYS_CHROOT",
        code = "161",
        decimal = "161",
        hex = "0xA1",
        octal = "241",
        description = "Change root directory.",
      },
      {
        label = "SYS_MOUNT",
        code = "165",
        decimal = "165",
        hex = "0xA5",
        octal = "245",
        description = "Mount a filesystem.",
      },
      {
        label = "SYS_UMASK",
        code = "95",
        decimal = "95",
        hex = "0x5F",
        octal = "137",
        description = "Set file creation mode mask.",
      },
      {
        label = "SYS_OPENAT",
        code = "257",
        decimal = "257",
        hex = "0x101",
        octal = "401",
        description = "Open a file relative to a directory descriptor.",
      },
      {
        label = "SYS_NEWFSTATAT",
        code = "262",
        decimal = "262",
        hex = "0x106",
        octal = "406",
        description = "Get file status relative to a directory file descriptor.",
      },
      {
        label = "SYS_ACCEPT4",
        code = "288",
        decimal = "288",
        hex = "0x120",
        octal = "440",
        description = "Accept a socket connection with flags.",
      },
      {
        label = "SYS_DUP3",
        code = "292",
        decimal = "292",
        hex = "0x124",
        octal = "444",
        description = "Duplicate a file descriptor with flags.",
      },
      {
        label = "SYS_PIPE2",
        code = "293",
        decimal = "293",
        hex = "0x125",
        octal = "445",
        description = "Create a pipe with flags.",
      },
      {
        label = "SYS_EPOLL_CREATE1",
        code = "291",
        decimal = "291",
        hex = "0x123",
        octal = "443",
        description = "Create an epoll instance.",
      },
      {
        label = "SYS_PRLIMIT64",
        code = "302",
        decimal = "302",
        hex = "0x12E",
        octal = "456",
        description = "Get or set process resource limits.",
      },
      {
        label = "SYS_GETRANDOM",
        code = "318",
        decimal = "318",
        hex = "0x13E",
        octal = "476",
        description = "Get random bytes from the kernel.",
      },
    },
  },
}

-- Try to augment the `syscalls` entries with legacy int0x80 (i386) numbers
local function parse_syscall_header(path)
  local map = {}
  local f = io.open(path, "r")
  if not f then
    return map
  end
  for line in f:lines() do
    local name, num = string.match(line, "^#define%s+__NR_([%w_]+)%s+([%-]?%d+)")
    if name and num then
      map[string.lower(name)] = tonumber(num)
    end
  end
  f:close()
  return map
end

local function augment_syscalls_with_legacy()
  local map32 = parse_syscall_header("/usr/include/asm/unistd_32.h")
  if not entries or not entries.syscalls or not entries.syscalls.items then
    return
  end
  for _, it in ipairs(entries.syscalls.items) do
    if it.label then
      local lname = string.lower(it.label or "")
      local key = lname:gsub("^sys_", ""):gsub("^sys", ""):gsub("^__", "")
      key = key:gsub("^syscall_", "")
      key = key:gsub("^_", "")
      local candidates = { key, key:gsub("^sys_", ""), key:gsub("^sys", "") }
      local found
      for _, c in ipairs(candidates) do
        if map32[c] then
          found = map32[c]
          break
        end
      end
      if not found then
        local alt = key:gsub("^sys_", "")
        if map32[alt] then
          found = map32[alt]
        end
      end
      if found then
        it.int80_decimal = tostring(found)
        it.int80_hex = string.format("0x%02X", found)
        it.int80_octal = string.format("%03o", found)
      end
    end
  end
end

augment_syscalls_with_legacy()

local function make_entry(item)
  local telescope = get_telescope()
  local ordinal = table.concat({
    item.label or "",
    item.code or "",
    item.decimal or item.hex or item.octal or "",
  }, " ")

  if not telescope then
    return {
      value = item,
      ordinal = ordinal,
      display = function(entry)
        return (entry.value.label or "") .. " " .. (entry.value.code or "")
      end,
      preview = make_preview(item),
    }
  end

  local suffix = item.char and ("char=" .. item.char) or ""
  local description = item.description or ""
  local alt = ""
  if item.decimal and item.hex then
    alt = item.decimal .. " / " .. item.hex
  elseif item.decimal and item.octal then
    alt = item.decimal .. " / " .. item.octal
  else
    alt = item.decimal or item.hex or item.octal or ""
  end
  if item.int80_decimal then
    local int80_hex = item.int80_hex or (item.int80_decimal and string.format("0x%02X", tonumber(item.int80_decimal)))
    alt = alt .. (alt ~= "" and " | " or "") .. ("int80: " .. item.int80_decimal .. " / " .. (int80_hex or ""))
  end

  local desc_display = description ~= "" and description or suffix

  return {
    value = item,
    ordinal = ordinal,
    display = function(entry)
      return telescope.make_display({
        { entry.value.label or "", "TelescopeResultsIdentifier" },
        { entry.value.code or "", "TelescopeResultsComment" },
        { alt, "TelescopeResultsIdentifier" },
        { desc_display, "TelescopeResultsSpecialComment" },
      })
    end,
    preview = make_preview(item),
  }
end

local function keep_buf(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "asm")
end

local function open_category(name)
  local telescope = get_telescope()
  if not telescope then
    vim.notify("AsmInfo: telescope is not available", vim.log.levels.WARN)
    return
  end

  local entry = entries[name]
  if not entry then
    vim.notify("AsmInfo: unknown category: " .. tostring(name), vim.log.levels.WARN)
    return
  end

  telescope.pickers
    .new({}, {
      prompt_title = entry.title,
      finder = telescope.finders.new_table({
        results = entry.items,
        entry_maker = make_entry,
      }),
      previewer = telescope.previewers.new_buffer_previewer({
        define_preview = function(self, entry)
          keep_buf(self.state.bufnr)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.preview)
        end,
      }),
      sorter = telescope.conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        telescope.actions.select_default:replace(function()
          telescope.actions.close(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end

function M.open(category)
  open_category(category or "constants")
end

function M.open_do()
  open_do_window()
end

function M.setup()
  local names = vim.tbl_keys(entries)
  table.sort(names)

  vim.api.nvim_create_user_command("AsmInfo", function(opts)
    M.open(opts.args ~= "" and opts.args or "constants")
  end, {
    nargs = "?",
    complete = function(_, _, _)
      return names
    end,
    desc = "Open assembly info helper window.",
  })

  vim.api.nvim_create_user_command("AsmConstants", function()
    M.open("constants")
  end, { desc = "Open common NASM constants." })

  vim.api.nvim_create_user_command("AsmAscii", function()
    M.open("ascii")
  end, { desc = "Open ASCII reference." })

  vim.api.nvim_create_user_command("AsmHex", function()
    M.open("hex")
  end, { desc = "Open common hexadecimal values." })

  vim.api.nvim_create_user_command("AsmOctal", function()
    M.open("octal")
  end, { desc = "Open common octal values." })

  vim.api.nvim_create_user_command("AsmBinary", function()
    M.open("binary")
  end, { desc = "Open binary values." })

  vim.api.nvim_create_user_command("AsmDirectives", function()
    M.open("directives")
  end, { desc = "Open NASM directive reference." })

  vim.api.nvim_create_user_command("AsmRegisters", function()
    M.open("registers")
  end, { desc = "Open x86_64 register reference." })

  vim.api.nvim_create_user_command("AsmInstructions", function()
    M.open("instructions")
  end, { desc = "Open x86_64 instruction reference." })

  vim.api.nvim_create_user_command("AsmSyscalls", function()
    M.open("syscalls")
  end, { desc = "Open x86_64 syscall numbers." })

  vim.api.nvim_create_user_command("AsmDo", function()
    M.open_do()
  end, { desc = "Open interactive conversion helper." })
end

M.setup()
return M
