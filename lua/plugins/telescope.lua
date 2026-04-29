return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      { "<leader>f", "", desc = "FFind Telescope" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      { "<leader>fr", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>ft", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fw", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope treesitter<cr>", desc = "Treesitter Symbols" },
      { "<leader>fc", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "LSP Incoming Calls" },
      { "<leader>fw", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "File Browser" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      {
        "<leader>fg",
        function()
          if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):find("true") then
            require("telescope.builtin").git_files()
          else
            vim.notify("Not a git repository", vim.log.levels.WARN)
          end
        end,
        desc = "Git Files",
      },
      { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Marks" },
      { "<leader>fR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>fC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      {
        "<leader>fG",
        function()
          if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):find("true") then
            require("telescope.builtin").git_status()
          else
            vim.notify("Not a git repository", vim.log.levels.WARN)
          end
        end,
        desc = "Git Status",
      },
      {
        "<leader>fT",
        function()
          require("telescope.builtin").live_grep({
            default_text = "//\\s*(TODO|FIXME|HACK|NOTE|XXX)|#\\s*(TODO|FIXME|HACK|NOTE|XXX)|--\\s*(TODO|FIXME|HACK|NOTE|XXX)",
          })
        end,
        desc = "Search TODOs",
      },
    },
    opts = {
      defaults = {
        layout_strategy = "center",
        layout_config = {
          center = {
            preview_cutoff = 120,
            width = function(_, cols)
              return math.floor(cols * 0.85)
            end,
            height = function(_, _, lines)
              return math.floor(lines * 0.8)
            end,
          },
        },
        sorting_strategy = "ascending",
        prompt_position = "top",
        prompt_prefix = "   ",
        selection_caret = "  ",
        winblend = 0,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
      extensions = {
        file_browser = {
          hijack_netrw = true,
          grouped = true,
          hidden = true,
          respect_gitignore = false,
        },
      },
    },
    config = function(_, opts)
      local actions = require("telescope.actions")
      opts.extensions.file_browser.mappings = {
        n = {
          ["l"] = actions.select_default,
        },
      }
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("file_browser")
    end,
  },
}
