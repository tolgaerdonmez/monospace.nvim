-- Monospace theme for Neovim
-- A minimalistic theme with subtle purple accents

local M = {}

-- Default configuration
local default_config = {
  variant = "dark", -- "dark" or "light"
  setup_lualine = true, -- Automatically setup lualine theme
  setup_tmux = false, -- Automatically setup tmux status line colors
}

-- Current configuration
local config = {}

function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", default_config, opts)
  
  -- Load the appropriate theme
  if config.variant == "light" then
    require("monospace.themes.light").setup()
  else
    require("monospace.themes.dark").setup()
  end
  
  -- Auto-configure lualine if available
  if config.setup_lualine ~= false then
    M.setup_lualine(config.variant)
  end
  
  -- Auto-configure tmux if enabled
  if config.setup_tmux then
    require("monospace.tmux").setup(config.variant)
  end
end

-- Setup lualine theme
function M.setup_lualine(variant)
  variant = variant or config.variant or "dark"
  
  -- Check if lualine is installed
  local lualine_ok, lualine = pcall(require, "lualine")
  if not lualine_ok then
    return
  end
  
  -- Set the theme
  local theme_name = variant == "light" and "monospace_light" or "monospace_dark"
  lualine.setup({
    options = {
      theme = theme_name,
    },
  })
end

-- Convenience functions
function M.load_dark()
  require("monospace.themes.dark").setup()
end

function M.load_light()
  require("monospace.themes.light").setup()
end

return M

