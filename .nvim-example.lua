-- Example Neovim configuration for Monospace theme
-- Add this to your init.lua or colorscheme configuration

-- Using lazy.nvim
-- {
--   "keksiqc/monospace-theme",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     require("monospace").setup({
--       variant = "dark", -- or "light"
--     })
--   end,
-- }

-- Or use directly:
require("monospace").setup({
  variant = "dark", -- Options: "dark" or "light"
})

-- Or use colorscheme command:
-- vim.cmd("colorscheme monospace-dark")
-- vim.cmd("colorscheme monospace-light")

