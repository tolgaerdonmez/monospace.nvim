-- Lualine theme for Monospace Light

local function get_colors()
  -- Try to get colors from the monospace theme
  local ok, monospace_colors = pcall(function()
    -- Load theme JSON
    local theme_path = vim.fn.findfile("themes/monospace-light.json", vim.fn.join(vim.api.nvim_list_runtime_paths(), ","))
    
    if theme_path == "" then
      local script_path = debug.getinfo(1, "S").source:match("@(.*)")
      if script_path then
        local script_dir = vim.fn.fnamemodify(script_path, ":h")
        theme_path = vim.fn.fnamemodify(script_dir .. "/../../../themes/monospace-light.json", ":p")
      end
    end
    
    local theme_file = io.open(theme_path, "r")
    if not theme_file then return nil end
    
    local theme_json = theme_file:read("*a")
    theme_file:close()
    
    local theme_data
    if vim.json then
      theme_data = vim.json.decode(theme_json)
    else
      theme_data = vim.fn.json_decode(theme_json)
    end
    
    return require("monospace.colors").extract_colors(theme_data)
  end)
  
  if ok and monospace_colors then
    return monospace_colors
  end
  
  -- Fallback colors if theme can't be loaded
  return {
    bg = "#ffffff",
    fg = "#1f2939",
    line_highlight = "#f4f7fd",
    border = "#a4afbd",
    error = "#df4047",
    warning = "#df8128",
    info = "#5173f1",
    hint = "#17975f",
    git_add = "#17975f",
    git_change = "#5173f1",
    git_delete = "#df4047",
    function_name = "#6f4cde",
  }
end

local colors = get_colors()

-- Extract statusbar colors from VSCode theme
local function get_statusbar_colors()
  local theme_path = vim.fn.findfile("themes/monospace-light.json", vim.fn.join(vim.api.nvim_list_runtime_paths(), ","))
  
  if theme_path == "" then
    local script_path = debug.getinfo(1, "S").source:match("@(.*)")
    if script_path then
      local script_dir = vim.fn.fnamemodify(script_path, ":h")
      theme_path = vim.fn.fnamemodify(script_dir .. "/../../../themes/monospace-light.json", ":p")
    end
  end
  
  local theme_file = io.open(theme_path, "r")
  if not theme_file then
    return {
      bg = "#ffffff",
      fg = "#5d6a7d",
      border = "#d9dfe7",
    }
  end
  
  local theme_json = theme_file:read("*a")
  theme_file:close()
  
  local theme_data
  if vim.json then
    theme_data = vim.json.decode(theme_json)
  else
    theme_data = vim.fn.json_decode(theme_json)
  end
  
  local c = theme_data.colors or {}
  
  -- Helper to strip alpha
  local function strip_alpha(color)
    if color and #color == 9 then
      return color:sub(1, 7)
    end
    return color
  end
  
  return {
    bg = strip_alpha(c["statusBar.background"] or "#ffffff"),
    fg = strip_alpha(c["statusBar.foreground"] or "#5d6a7d"),
    border = strip_alpha(c["statusBar.border"] or "#d9dfe7"),
    active_bg = strip_alpha(c["tab.activeBackground"] or "#ffffff"),
    active_fg = strip_alpha(c["tab.activeForeground"] or "#333e4f"),
  }
end

local statusbar = get_statusbar_colors()

return {
  normal = {
    a = { bg = colors.function_name or "#6f4cde", fg = colors.bg, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.fg },
    c = { bg = statusbar.bg, fg = statusbar.fg },
    x = { bg = statusbar.bg, fg = statusbar.fg },
    y = { bg = colors.line_highlight, fg = colors.fg },
    z = { bg = colors.function_name or "#6f4cde", fg = colors.bg, gui = "bold" },
  },
  insert = {
    a = { bg = colors.git_add, fg = colors.bg, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.fg },
    c = { bg = statusbar.bg, fg = statusbar.fg },
    x = { bg = statusbar.bg, fg = statusbar.fg },
    y = { bg = colors.line_highlight, fg = colors.fg },
    z = { bg = colors.git_add, fg = colors.bg, gui = "bold" },
  },
  visual = {
    a = { bg = colors.warning, fg = colors.bg, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.fg },
    c = { bg = statusbar.bg, fg = statusbar.fg },
    x = { bg = statusbar.bg, fg = statusbar.fg },
    y = { bg = colors.line_highlight, fg = colors.fg },
    z = { bg = colors.warning, fg = colors.bg, gui = "bold" },
  },
  replace = {
    a = { bg = colors.error, fg = colors.bg, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.fg },
    c = { bg = statusbar.bg, fg = statusbar.fg },
    x = { bg = statusbar.bg, fg = statusbar.fg },
    y = { bg = colors.line_highlight, fg = colors.fg },
    z = { bg = colors.error, fg = colors.bg, gui = "bold" },
  },
  command = {
    a = { bg = colors.info, fg = colors.bg, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.fg },
    c = { bg = statusbar.bg, fg = statusbar.fg },
    x = { bg = statusbar.bg, fg = statusbar.fg },
    y = { bg = colors.line_highlight, fg = colors.fg },
    z = { bg = colors.info, fg = colors.bg, gui = "bold" },
  },
  inactive = {
    a = { bg = colors.line_highlight, fg = colors.border, gui = "bold" },
    b = { bg = colors.line_highlight, fg = colors.border },
    c = { bg = statusbar.bg, fg = colors.border },
    x = { bg = statusbar.bg, fg = colors.border },
    y = { bg = colors.line_highlight, fg = colors.border },
    z = { bg = colors.line_highlight, fg = colors.border, gui = "bold" },
  },
}

