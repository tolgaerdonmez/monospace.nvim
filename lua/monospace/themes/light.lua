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
    NormalFloat = { fg = colors.fg, bg = colors.quick_input_bg },
    NormalNC = { fg = colors.fg, bg = colors.bg },
    FloatBorder = { fg = colors.border, bg = colors.quick_input_bg },
    
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
    
    -- Pmenu (Popup menu - matches dropdown/menu colors)
    Pmenu = { fg = colors.menu_fg, bg = colors.menu_bg },
    PmenuSel = { fg = colors.menu_selection_fg, bg = colors.menu_selection_bg },
    PmenuSbar = { bg = colors.dropdown_list_bg },
    PmenuThumb = { bg = colors.border },
    PmenuKind = { fg = colors.function_name or "#6f4cde" },
    PmenuExtra = { fg = colors.line_number },
    
    -- Fold
    Folded = { fg = colors.comment, bg = colors.line_highlight },
    FoldColumn = { fg = colors.line_number },
    
    -- Sign column
    SignColumn = { bg = colors.bg },
    
    -- Vert split - make invisible for VSCode-like clean boundary
    VertSplit = { fg = colors.sidebar_bg, bg = colors.sidebar_bg },
    WinSeparator = { fg = colors.sidebar_bg, bg = colors.sidebar_bg },
    
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
    
    -- Markdown
    markdownH1 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownH2 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownH3 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownH4 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownH5 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownH6 = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownHeadingDelimiter = { fg = colors.markdown_heading or "#264dcb", bold = true },
    markdownHeadingRule = { fg = colors.border },
    markdownBold = { fg = colors.markdown_bold or "#d07826", bold = true },
    markdownItalic = { fg = colors.markdown_italic or "#0075a2", italic = true },
    markdownCode = { fg = colors.markdown_code or "#264dcb" },
    markdownCodeBlock = { fg = colors.markdown_code or "#264dcb", bg = colors.line_highlight },
    markdownCodeDelimiter = { fg = colors.markdown_code or "#264dcb" },
    markdownInlineCode = { fg = colors.markdown_inline_code or "#007b49" },
    markdownCodeBlockDelimiter = { fg = colors.markdown_code or "#264dcb" },
    markdownBlockquote = { fg = colors.markdown_quote or "#007b49" },
    markdownQuote = { fg = colors.markdown_quote or "#007b49" },
    markdownLink = { fg = colors.markdown_link or "#007b49", underline = true },
    markdownLinkText = { fg = colors.markdown_link or "#007b49" },
    markdownUrl = { fg = colors.markdown_link or "#007b49", underline = true },
    markdownListMarker = { fg = colors.markdown_list or "#d07826" },
    markdownOrderedListMarker = { fg = colors.markdown_list or "#d07826" },
    markdownStrikethrough = { fg = colors.markdown_strikethrough or "#ad1c48", strikethrough = true },
    markdownEscape = { fg = colors.fg },
    markdownRule = { fg = colors.border },
    
    -- Treesitter markdown
    ["@markup.heading"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.1"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.2"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.3"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.4"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.5"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.heading.6"] = { fg = colors.markdown_heading or "#264dcb", bold = true },
    ["@markup.strong"] = { fg = colors.markdown_bold or "#d07826", bold = true },
    ["@markup.italic"] = { fg = colors.markdown_italic or "#0075a2", italic = true },
    ["@markup.quote"] = { fg = colors.markdown_quote or "#007b49" },
    ["@markup.strikethrough"] = { fg = colors.markdown_strikethrough or "#ad1c48", strikethrough = true },
    ["@markup.link"] = { fg = colors.markdown_link or "#007b49", underline = true },
    ["@markup.link.url"] = { fg = colors.markdown_link or "#007b49", underline = true },
    ["@markup.list"] = { fg = colors.markdown_list or "#d07826" },
    ["@markup.list.numbered"] = { fg = colors.markdown_list or "#d07826" },
    ["@markup.list.unnumbered"] = { fg = colors.markdown_list or "#d07826" },
    ["@markup.raw"] = { fg = colors.markdown_code or "#264dcb" },
    ["@markup.raw.block"] = { fg = colors.markdown_code or "#264dcb", bg = colors.line_highlight },
    ["@markup.raw.inline"] = { fg = colors.markdown_inline_code or "#007b49" },
    
    -- NvimTree (File Explorer)
    NvimTreeNormal = { fg = colors.sidebar_fg, bg = colors.sidebar_bg },
    NvimTreeNormalNC = { fg = colors.sidebar_fg, bg = colors.sidebar_bg },
    NvimTreeEndOfBuffer = { fg = colors.sidebar_bg, bg = colors.sidebar_bg },
    NvimTreeRootFolder = { fg = colors.sidebar_title, bold = true },
    NvimTreeFolderIcon = { fg = colors.function_name or "#6f4cde" },
    NvimTreeFolderName = { fg = colors.sidebar_fg },
    NvimTreeOpenedFolderName = { fg = colors.sidebar_fg, bold = true },
    NvimTreeClosedFolderName = { fg = colors.sidebar_fg },
    NvimTreeEmptyFolderName = { fg = colors.line_number },
    NvimTreeIndentMarker = { fg = colors.tree_indent },
    NvimTreeWinSeparator = { fg = colors.sidebar_bg, bg = colors.sidebar_bg },
    NvimTreeWindowPicker = { fg = colors.sidebar_fg, bg = colors.list_selection_bg, bold = true },
    
    -- NvimTree Git
    NvimTreeGitNew = { fg = colors.git_add },
    NvimTreeGitDirty = { fg = colors.git_change },
    NvimTreeGitDeleted = { fg = colors.git_delete },
    NvimTreeGitStaged = { fg = colors.git_add },
    NvimTreeGitMerge = { fg = colors.warning },
    NvimTreeGitRenamed = { fg = colors.info },
    
    -- NvimTree Diagnostics
    NvimTreeDiagnosticError = { fg = colors.error },
    NvimTreeDiagnosticWarn = { fg = colors.warning },
    NvimTreeDiagnosticInfo = { fg = colors.info },
    NvimTreeDiagnosticHint = { fg = colors.hint },
    
    -- NvimTree Selection/Hover
    NvimTreeCursorLine = { bg = colors.list_hover_bg },
    NvimTreeNormalFloat = { fg = colors.sidebar_fg, bg = colors.sidebar_bg },
    
    -- Telescope (Command Palette)
    TelescopePromptBorder = { fg = colors.border, bg = colors.quick_input_bg },
    TelescopeResultsBorder = { fg = colors.border, bg = colors.quick_input_bg },
    TelescopePreviewBorder = { fg = colors.border, bg = colors.bg },
    TelescopePromptTitle = { fg = colors.sidebar_title, bg = colors.quick_input_bg },
    TelescopeResultsTitle = { fg = colors.sidebar_title, bg = colors.quick_input_bg },
    TelescopePreviewTitle = { fg = colors.sidebar_title, bg = colors.bg },
    TelescopePromptNormal = { fg = colors.quick_input_fg, bg = colors.quick_input_bg },
    TelescopeResultsNormal = { fg = colors.quick_input_fg, bg = colors.quick_input_bg },
    TelescopePreviewNormal = { fg = colors.fg, bg = colors.bg },
    TelescopePromptCounter = { fg = colors.line_number, bg = colors.quick_input_bg },
    TelescopeResultsCounter = { fg = colors.line_number, bg = colors.quick_input_bg },
    TelescopePreviewCounter = { fg = colors.line_number, bg = colors.bg },
    TelescopeMatching = { fg = colors.function_name or "#6f4cde", bold = true },
    TelescopeSelection = { bg = colors.list_selection_bg, fg = colors.list_selection_fg },
    TelescopeSelectionCaret = { fg = colors.function_name or "#6f4cde" },
    TelescopeMultiSelection = { bg = colors.list_inactive_selection_bg },
    TelescopeNormal = { fg = colors.fg, bg = colors.quick_input_bg },
    TelescopeBorder = { fg = colors.border },
    TelescopePromptPrefix = { fg = colors.function_name or "#6f4cde" },
    
    -- WhichKey
    WhichKey = { fg = colors.function_name or "#6f4cde" },
    WhichKeyGroup = { fg = colors.fg },
    WhichKeySeparator = { fg = colors.border },
    WhichKeyDesc = { fg = colors.sidebar_fg },
    WhichKeyFloat = { bg = colors.quick_input_bg },
    
    -- Notify
    NotifyBackground = { bg = colors.panel_bg },
    NotifyBorder = { fg = colors.panel_border },
    NotifyINFOBorder = { fg = colors.info },
    NotifyWARNBorder = { fg = colors.warning },
    NotifyERRORBorder = { fg = colors.error },
    NotifyDEBUGBorder = { fg = colors.line_number },
    NotifyTRACEBorder = { fg = colors.function_name or "#6f4cde" },
    NotifyINFOTitle = { fg = colors.info },
    NotifyWARNTitle = { fg = colors.warning },
    NotifyERRORTitle = { fg = colors.error },
    NotifyINFOBody = { fg = colors.fg, bg = colors.panel_bg },
    NotifyWARNBody = { fg = colors.fg, bg = colors.panel_bg },
    NotifyERRORBody = { fg = colors.fg, bg = colors.panel_bg },
    
    -- Noice
    NoiceCmdline = { bg = colors.quick_input_bg },
    NoiceCmdlineIcon = { fg = colors.function_name or "#6f4cde" },
    NoiceCmdlineIconSearch = { fg = colors.warning },
    NoiceCmdlinePopup = { bg = colors.quick_input_bg },
    NoiceCmdlinePopupBorder = { fg = colors.border },
    NoiceCmdlinePopupTitle = { fg = colors.sidebar_title },
    
    -- Bufferline
    BufferLineFill = { bg = colors.sidebar_bg },
    BufferLineBackground = { fg = colors.line_number, bg = colors.sidebar_bg },
    BufferLineBufferSelected = { fg = colors.fg, bg = colors.bg, bold = true },
    BufferLineBufferVisible = { fg = colors.line_number, bg = colors.sidebar_bg },
    BufferLineIndicatorSelected = { fg = colors.function_name or "#6f4cde" },
    BufferLineIndicatorVisible = { fg = colors.border },
    BufferLineSeparator = { fg = colors.sidebar_border, bg = colors.sidebar_bg },
    BufferLineSeparatorSelected = { fg = colors.border, bg = colors.bg },
    BufferLineSeparatorVisible = { fg = colors.sidebar_border, bg = colors.sidebar_bg },
    BufferLineCloseButton = { fg = colors.line_number, bg = colors.sidebar_bg },
    BufferLineCloseButtonSelected = { fg = colors.error, bg = colors.bg },
    BufferLineCloseButtonVisible = { fg = colors.line_number, bg = colors.sidebar_bg },
    BufferLineModified = { fg = colors.git_change, bg = colors.sidebar_bg },
    BufferLineModifiedSelected = { fg = colors.git_change, bg = colors.bg },
    BufferLineModifiedVisible = { fg = colors.git_change, bg = colors.sidebar_bg },
    BufferLineTab = { fg = colors.line_number, bg = colors.sidebar_bg },
    BufferLineTabSelected = { fg = colors.fg, bg = colors.bg },
    BufferLineTabClose = { fg = colors.error, bg = colors.sidebar_bg },
    
    -- Indent Blankline
    IndentBlanklineChar = { fg = colors.tree_indent },
    IndentBlanklineContextChar = { fg = colors.border },
    IndentBlanklineSpaceChar = { fg = colors.tree_indent },
    IndentBlanklineContextStart = { sp = colors.border, underline = true },
    
    -- Dashboard
    DashboardHeader = { fg = colors.function_name or "#6f4cde" },
    DashboardFooter = { fg = colors.comment },
    DashboardCenter = { fg = colors.fg },
    DashboardShortCut = { fg = colors.line_number },
    DashboardIcon = { fg = colors.function_name or "#6f4cde" },
    
    -- Alpha
    AlphaHeader = { fg = colors.function_name or "#6f4cde" },
    AlphaFooter = { fg = colors.comment },
    AlphaButtons = { fg = colors.fg },
    AlphaShortcut = { fg = colors.line_number },
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

