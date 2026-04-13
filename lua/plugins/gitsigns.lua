return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = vim.keymap.set

        map("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next Hunk" })
        map("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev Hunk" })
        map("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
        map("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Stage Hunk" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo Stage Hunk" })
        map("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Reset Hunk" })
        map("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr, desc = "Stage Buffer" })
        map("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr, desc = "Reset Buffer" })
        map("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame Line" })
        map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = "Blame Line (full)" })
      end,
    },
  },
}
