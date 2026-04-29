return {
  {
    "CarlosDlw/nvim-lux",
    ft = "lux",
    opts = {},
    config = function(_, opts)
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        opts.lsp = opts.lsp or {}
        opts.lsp.capabilities = blink.get_lsp_capabilities()
      end
      require("lux").setup(opts)
    end,
  },
}
