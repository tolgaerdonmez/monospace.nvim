-- Color extraction utility for Monospace theme
-- Maps VSCode theme colors to Neovim highlight groups

local M = {}

-- Helper function to convert hex to RGB
local function hex_to_rgb(hex)
  if not hex or #hex < 7 then return nil end
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  return r, g, b
end

-- Helper function to convert RGB to hex
local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r), math.floor(g), math.floor(b))
end

-- Helper function to blend color with background based on alpha
local function blend_with_bg(color, bg_color)
  if not color or not bg_color then return color end
  
  local color_hex = color:sub(1, 7)
  local alpha_hex = color:sub(8, 9)
  
  -- If no alpha channel or fully opaque, return as-is
  if #color < 9 or alpha_hex == "ff" then
    return color_hex
  end
  
  -- Parse alpha (0-255)
  local alpha = tonumber(alpha_hex, 16) / 255.0
  
  -- Get RGB values
  local cr, cg, cb = hex_to_rgb(color_hex)
  local br, bg, bb = hex_to_rgb(bg_color)
  
  if not cr or not br then return color_hex end
  
  -- Blend: result = color * alpha + background * (1 - alpha)
  local r = cr * alpha + br * (1 - alpha)
  local g = cg * alpha + bg * (1 - alpha)
  local b = cb * alpha + bb * (1 - alpha)
  
  return rgb_to_hex(r, g, b)
end

-- Helper function to strip alpha channel from hex colors
-- For colors with alpha, blends with background if provided
local function strip_alpha(color, bg_color)
  if not color then return color end
  
  if #color == 9 then
    -- Has alpha channel
    local alpha = color:sub(8, 9)
    if alpha == "ff" then
      -- Fully opaque, just strip alpha
      return color:sub(1, 7)
    elseif bg_color then
      -- Semi-transparent, blend with background
      return blend_with_bg(color, bg_color)
    else
      -- No background provided, just strip alpha (fallback)
      return color:sub(1, 7)
    end
  end
  
  return color
end

-- Extract colors from VSCode theme JSON
function M.extract_colors(theme_data)
  local colors = {}
  local c = theme_data.colors or {}
  
  -- Get background first (needed for blending)
  local bg_raw = c["editor.background"] or "#171f2b"
  colors.bg = strip_alpha(bg_raw)
  
  -- Basic colors (blend with background if needed)
  colors.fg = strip_alpha(c.foreground or "#d9dfe7", colors.bg)
  
  -- Editor colors (blend semi-transparent colors with background)
  colors.cursor = strip_alpha(c["editorCursor.foreground"] or "#e0ccff", colors.bg)
  colors.selection = strip_alpha(c["editor.selectionBackground"] or "#264dcb80", colors.bg)
  colors.line_highlight = strip_alpha(c["editor.lineHighlightBackground"] or "#1f2939", colors.bg)
  
  -- Line numbers
  colors.line_number = strip_alpha(c["editorLineNumber.foreground"] or "#475365", colors.bg)
  colors.line_number_active = strip_alpha(c["editorLineNumber.activeForeground"] or "#d9dfe7", colors.bg)
  
  -- Diagnostics
  colors.error = strip_alpha(c["editorError.foreground"] or "#fc8f8e", colors.bg)
  colors.warning = strip_alpha(c["editorWarning.foreground"] or "#ffc26e", colors.bg)
  colors.info = strip_alpha(c["editorInfo.foreground"] or "#a2b6ff", colors.bg)
  colors.hint = strip_alpha(c["editorHint.foreground"] or "#66ce98", colors.bg)
  
  -- Git signs
  colors.git_add = strip_alpha(c["gitDecoration.addedResourceForeground"] or "#17b877", colors.bg)
  colors.git_change = strip_alpha(c["gitDecoration.modifiedResourceForeground"] or "#708fff", colors.bg)
  colors.git_delete = strip_alpha(c["gitDecoration.deletedResourceForeground"] or "#f76769", colors.bg)
  
  -- Diff (these often have alpha, blend with background)
  colors.diff_add = strip_alpha(c["diffEditor.insertedTextBackground"] or "#17975f40", colors.bg)
  colors.diff_delete = strip_alpha(c["diffEditor.removedTextBackground"] or "#df404740", colors.bg)
  
  -- Comments
  colors.comment = nil -- Will be set from tokenColors
  
  -- Syntax colors (from tokenColors)
  local token_colors = {}
  if theme_data.tokenColors then
    for _, token in ipairs(theme_data.tokenColors) do
      if token.scope and token.settings then
        local scope = type(token.scope) == "table" and token.scope[1] or token.scope
        if scope == "comment" or scope == "punctuation.definition.comment" then
          colors.comment = strip_alpha(token.settings.foreground or "#7f8d9f", colors.bg)
        elseif scope == "keyword" then
          token_colors.keyword = strip_alpha(token.settings.foreground or "#fd8da3", colors.bg)
        elseif scope == "string" or scope == "punctuation.definition.string" then
          token_colors.string = strip_alpha(token.settings.foreground or "#77d5a3", colors.bg)
        elseif scope == "constant" or scope == "entity.name.constant" then
          token_colors.constant = strip_alpha(token.settings.foreground or "#92a9ff", colors.bg)
        elseif scope == "entity" or scope == "entity.name" then
          token_colors.function_name = strip_alpha(token.settings.foreground or "#bd9cfe", colors.bg)
        elseif scope == "variable" then
          token_colors.variable = strip_alpha(token.settings.foreground or "#ffd395", colors.bg)
        elseif scope == "support" then
          token_colors.type = strip_alpha(token.settings.foreground or "#92a9ff", colors.bg)
        end
      end
    end
  end
  
  -- Fallback comment color
  if not colors.comment then
    colors.comment = strip_alpha(c["descriptionForeground"] or "#8b98a9", colors.bg)
  end
  
  -- Merge token colors
  for k, v in pairs(token_colors) do
    colors[k] = v
  end
  
  -- Terminal colors (terminal colors are usually opaque)
  colors.terminal = {
    black = strip_alpha(c["terminal.ansiBlack"] or "#738295", colors.bg),
    red = strip_alpha(c["terminal.ansiRed"] or "#f76769", colors.bg),
    green = strip_alpha(c["terminal.ansiGreen"] or "#17b877", colors.bg),
    yellow = strip_alpha(c["terminal.ansiYellow"] or "#ffa23e", colors.bg),
    blue = strip_alpha(c["terminal.ansiBlue"] or "#708fff", colors.bg),
    magenta = strip_alpha(c["terminal.ansiMagenta"] or "#a87ffb", colors.bg),
    cyan = strip_alpha(c["terminal.ansiCyan"] or "#25a6e9", colors.bg),
    white = strip_alpha(c["terminal.ansiWhite"] or "#a4afbd", colors.bg),
    bright_black = strip_alpha(c["terminal.ansiBrightBlack"] or "#8b98a9", colors.bg),
    bright_red = strip_alpha(c["terminal.ansiBrightRed"] or "#fc8f8e", colors.bg),
    bright_green = strip_alpha(c["terminal.ansiBrightGreen"] or "#66ce98", colors.bg),
    bright_yellow = strip_alpha(c["terminal.ansiBrightYellow"] or "#ffc26e", colors.bg),
    bright_blue = strip_alpha(c["terminal.ansiBrightBlue"] or "#a2b6ff", colors.bg),
    bright_magenta = strip_alpha(c["terminal.ansiBrightMagenta"] or "#c8aaff", colors.bg),
    bright_cyan = strip_alpha(c["terminal.ansiBrightCyan"] or "#71c2ee", colors.bg),
    bright_white = strip_alpha(c["terminal.ansiBrightWhite"] or "#fafbfe", colors.bg),
  }
  
  -- UI colors (blend semi-transparent colors)
  colors.border = strip_alpha(c["editorWidget.border"] or "#5d6a7d", colors.bg)
  colors.visual = strip_alpha(c["editor.selectionBackground"] or "#264dcb80", colors.bg)
  colors.search = strip_alpha(c["editor.findMatchBackground"] or "#83431466", colors.bg)
  
  return colors
end

return M

