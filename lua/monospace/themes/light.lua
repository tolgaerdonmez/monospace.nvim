-- Monospace Light theme for Neovim

local M = {}

function M.setup()
  -- Load theme JSON
  -- Find the theme file in runtime path
  local theme_path = vim.fn.findfile("themes/monospace-light.json", vim.fn.join(vim.api.nvim_list_runtime_paths(), ","))
  
  if theme_path == "" then
    -- Fallback: try relative to script location
    local script_path = debug.getinfo(1, "S").source:match("@(.*)")
    if script_path then
      local script_dir = vim.fn.fnamemodify(script_path, ":h")
      theme_path = vim.fn.fnamemodify(script_dir .. "/../../../themes/monospace-light.json", ":p")
    end
  end
  
  local theme_file = io.open(theme_path, "r")
  if not theme_file then
    vim.notify("Monospace: Could not load theme file at: " .. (theme_path or "unknown"), vim.log.levels.ERROR)
    return
  end
  
  local theme_json = theme_file:read("*a")
  theme_file:close()
  
  -- Parse JSON (Neovim 0.7+ uses vim.json, older versions use vim.fn.json_decode)
  local theme_data
  if vim.json then
    theme_data = vim.json.decode(theme_json)
  else
    theme_data = vim.fn.json_decode(theme_json)
  end
  local colors = require("monospace.colors").extract_colors(theme_data)
  
  -- Enable true color support (required for accurate color rendering)
  vim.opt.termguicolors = true
  
  -- Set background
  vim.opt.background = "light"
  
  -- Clear existing highlights
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  -- Set color scheme name
  vim.g.colors_name = "monospace-light"
  
  -- Define highlight groups
  local highlights = {
    -- Basic
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.bg },
    NormalNC = { fg = colors.fg, bg = colors.bg },
    FloatBorder = { fg = colors.border, bg = colors.bg },
    
    -- Cursor
    Cursor = { fg = colors.bg, bg = colors.cursor },
    CursorLine = { bg = colors.line_highlight },
    CursorLineNr = { fg = colors.line_number_active, bold = true },
    CursorColumn = { bg = colors.line_highlight },
    
    -- Line numbers
    LineNr = { fg = colors.line_number },
    CursorLineNr = { fg = colors.line_number_active, bold = true },
    
    -- Selection
    Visual = { bg = colors.visual },
    VisualNOS = { bg = colors.visual },
    
    -- Search
    Search = { bg = colors.search },
    IncSearch = { bg = colors.search, bold = true },
    CurSearch = { bg = colors.search, bold = true },
    
    -- Diagnostics
    DiagnosticError = { fg = colors.error },
    DiagnosticWarn = { fg = colors.warning },
    DiagnosticInfo = { fg = colors.info },
    DiagnosticHint = { fg = colors.hint },
    DiagnosticUnderlineError = { sp = colors.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = colors.warning, undercurl = true },
    DiagnosticUnderlineInfo = { sp = colors.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = colors.hint, undercurl = true },
    
    -- Git signs
    GitSignsAdd = { fg = colors.git_add },
    GitSignsChange = { fg = colors.git_change },
    GitSignsDelete = { fg = colors.git_delete },
    GitSignsAddNr = { fg = colors.git_add },
    GitSignsChangeNr = { fg = colors.git_change },
    GitSignsDeleteNr = { fg = colors.git_delete },
    
    -- Diff
    DiffAdd = { bg = colors.diff_add },
    DiffDelete = { bg = colors.diff_delete },
    DiffChange = { bg = colors.diff_add },
    DiffText = { bg = colors.diff_add },
    
    -- Syntax
    Comment = { fg = colors.comment, italic = true },
    Keyword = { fg = colors.keyword or "#c43058" },
    String = { fg = colors.string or "#007b49" },
    Constant = { fg = colors.constant or "#264dcb" },
    Function = { fg = colors.function_name or "#6f4cde" },
    Identifier = { fg = colors.variable or "#d07826" },
    Type = { fg = colors.type or "#264dcb" },
    Statement = { fg = colors.keyword or "#c43058" },
    PreProc = { fg = colors.keyword or "#c43058" },
    Special = { fg = colors.string or "#007b49" },
    Underlined = { underline = true },
    Error = { fg = colors.error },
    Todo = { fg = colors.warning, bold = true },
    
    -- Status line
    StatusLine = { fg = colors.fg, bg = colors.bg },
    StatusLineNC = { fg = colors.line_number, bg = colors.bg },
    StatusLineTerm = { fg = colors.fg, bg = colors.bg },
    StatusLineTermNC = { fg = colors.line_number, bg = colors.bg },
    
    -- Tab line
    TabLine = { fg = colors.line_number, bg = colors.bg },
    TabLineFill = { bg = colors.bg },
    TabLineSel = { fg = colors.fg, bg = colors.bg, bold = true },
    
    -- Winbar
    WinBar = { fg = colors.fg, bg = colors.bg },
    WinBarNC = { fg = colors.line_number, bg = colors.bg },
    
    -- Pmenu
    Pmenu = { fg = colors.fg, bg = colors.line_highlight },
    PmenuSel = { fg = colors.fg, bg = colors.visual },
    PmenuSbar = { bg = colors.line_highlight },
    PmenuThumb = { bg = colors.border },
    
    -- Fold
    Folded = { fg = colors.comment, bg = colors.line_highlight },
    FoldColumn = { fg = colors.line_number },
    
    -- Sign column
    SignColumn = { bg = colors.bg },
    
    -- Vert split
    VertSplit = { fg = colors.border },
    
    -- Non-text
    NonText = { fg = colors.line_number },
    Whitespace = { fg = colors.line_number },
    
    -- Special keys
    SpecialKey = { fg = colors.line_number },
    
    -- Match paren
    MatchParen = { fg = colors.cursor, bold = true },
    
    -- Terminal
    Terminal = { fg = colors.fg, bg = colors.bg },
    
    -- LSP
    LspReferenceText = { bg = colors.line_highlight },
    LspReferenceRead = { bg = colors.line_highlight },
    LspReferenceWrite = { bg = colors.line_highlight },
    
    -- Treesitter (fallback if not using treesitter)
    ["@comment"] = { link = "Comment" },
    ["@keyword"] = { link = "Keyword" },
    ["@string"] = { link = "String" },
    ["@constant"] = { link = "Constant" },
    ["@function"] = { link = "Function" },
    ["@variable"] = { link = "Identifier" },
    ["@type"] = { link = "Type" },
    ["@parameter"] = { fg = colors.fg },
    ["@field"] = { fg = colors.type or "#0075a2" },
    ["@property"] = { fg = colors.type or "#0075a2" },
    ["@namespace"] = { fg = colors.function_name or "#6f4cde" },
    ["@tag"] = { fg = colors.string or "#007b49" },
    ["@punctuation"] = { fg = colors.fg },
    ["@operator"] = { fg = colors.fg },
    ["@number"] = { fg = colors.constant or "#264dcb" },
    ["@boolean"] = { fg = colors.constant or "#264dcb" },
    ["@error"] = { fg = colors.error },
    ["@warning"] = { fg = colors.warning },
  }
  
  -- Apply highlights
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
  
  -- Terminal colors
  vim.g.terminal_color_0 = colors.terminal.black
  vim.g.terminal_color_1 = colors.terminal.red
  vim.g.terminal_color_2 = colors.terminal.green
  vim.g.terminal_color_3 = colors.terminal.yellow
  vim.g.terminal_color_4 = colors.terminal.blue
  vim.g.terminal_color_5 = colors.terminal.magenta
  vim.g.terminal_color_6 = colors.terminal.cyan
  vim.g.terminal_color_7 = colors.terminal.white
  vim.g.terminal_color_8 = colors.terminal.bright_black
  vim.g.terminal_color_9 = colors.terminal.bright_red
  vim.g.terminal_color_10 = colors.terminal.bright_green
  vim.g.terminal_color_11 = colors.terminal.bright_yellow
  vim.g.terminal_color_12 = colors.terminal.bright_blue
  vim.g.terminal_color_13 = colors.terminal.bright_magenta
  vim.g.terminal_color_14 = colors.terminal.bright_cyan
  vim.g.terminal_color_15 = colors.terminal.bright_white
end

return M

