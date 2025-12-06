-- Tmux integration for Monospace theme
-- Changes tmux status line colors when Neovim is active to match lualine

local M = {}

-- Check if tmux is available
local function is_tmux()
  return vim.env.TMUX ~= nil
end

-- Execute tmux command
local function tmux(cmd)
  if not is_tmux() then
    return
  end
  vim.fn.system("tmux " .. cmd .. " 2>/dev/null")
end

-- Helpers to backup/restore tmux options so we can return to normal on exit
local function backup_option(opt, env_name)
  if not is_tmux() then
    return
  end
  local current = vim.fn.system(string.format("tmux show -g %s 2>/dev/null", opt)):match("= ?(.*)")
  if current then
    tmux(string.format("set-environment -g %s \"%s\"", env_name, current:gsub("\"", "\\\"")))
  end
end

local function restore_option(opt, env_name)
  if not is_tmux() then
    return
  end
  local val = vim.fn.system(string.format("tmux show-environment -g %s 2>/dev/null", env_name))
  local captured = val:match(env_name .. "=(.*)")
  if captured and #captured > 0 then
    tmux(string.format("set-option -g %s %s", opt, captured))
    tmux(string.format("set-environment -gru %s", env_name))
  else
    -- fallback to default
    tmux(string.format("set-option -g %s default", opt))
  end
end

-- Dark theme colors (matching lualine exactly)
local dark_colors = {
  -- Editor background
  bg = "#171f2b",
  -- Foreground
  fg = "#d9dfe7",
  -- Statusbar background (section c/x in lualine)
  statusbar_bg = "#1f2939",
  -- Statusbar foreground
  statusbar_fg = "#a4afbd",
  -- Line highlight (section b/y background)
  line_highlight = "#1f2939",
  -- Accent color (purple - section a/z in lualine)
  accent = "#bd9cfe",
  -- Border color
  border = "#333e4f",
  -- Inactive text
  inactive = "#5d6a7d",
}

-- Light theme colors (matching lualine exactly)
local light_colors = {
  -- Editor background
  bg = "#ffffff",
  -- Foreground
  fg = "#1f2939",
  -- Statusbar background
  statusbar_bg = "#ffffff",
  -- Statusbar foreground
  statusbar_fg = "#5d6a7d",
  -- Line highlight
  line_highlight = "#f4f7fd",
  -- Accent color (purple)
  accent = "#6f4cde",
  -- Border color
  border = "#d9dfe7",
  -- Inactive text
  inactive = "#a4afbd",
}

-- Set tmux status line colors to match lualine
function M.set_status_colors(variant)
  if not is_tmux() then
    return
  end
  
  -- Backup options first time we apply
  backup_option("status-left", "MONOSPACE_STATUS_LEFT_BACKUP")
  backup_option("status-right", "MONOSPACE_STATUS_RIGHT_BACKUP")
  backup_option("status-style", "MONOSPACE_STATUS_STYLE_BACKUP")
  backup_option("status-left-length", "MONOSPACE_STATUS_LEFT_LEN_BACKUP")
  backup_option("status-right-length", "MONOSPACE_STATUS_RIGHT_LEN_BACKUP")
  backup_option("window-status-format", "MONOSPACE_WIN_FMT_BACKUP")
  backup_option("window-status-current-format", "MONOSPACE_WIN_CUR_FMT_BACKUP")
  backup_option("window-status-style", "MONOSPACE_WIN_STYLE_BACKUP")
  backup_option("window-status-current-style", "MONOSPACE_WIN_CUR_STYLE_BACKUP")
  backup_option("window-status-activity-style", "MONOSPACE_WIN_ACT_STYLE_BACKUP")
  backup_option("window-status-bell-style", "MONOSPACE_WIN_BELL_STYLE_BACKUP")
  backup_option("pane-border-style", "MONOSPACE_PANE_BORDER_BACKUP")
  backup_option("pane-active-border-style", "MONOSPACE_PANE_ACTIVE_BORDER_BACKUP")
  backup_option("message-style", "MONOSPACE_MSG_STYLE_BACKUP")
  backup_option("message-command-style", "MONOSPACE_MSG_CMD_STYLE_BACKUP")
  backup_option("mode-style", "MONOSPACE_MODE_STYLE_BACKUP")

  local c = variant == "light" and light_colors or dark_colors
  
  -- Status bar style (matches lualine section c - the middle background)
  tmux(string.format('set-option -g status-style "bg=%s,fg=%s"', c.statusbar_bg, c.statusbar_fg))
  
  -- Powerline arrow characters (require Nerd Font / Powerline font)
  local arrow_right = ""  -- U+E0B0
  local arrow_left = ""   -- U+E0B2
  
  -- Status left: Create lualine-like sections with arrows
  -- Section a (purple) -> arrow -> Section b (line_highlight) -> arrow -> Section c (statusbar_bg)
  local status_left = string.format(
    '#[bg=%s,fg=%s,bold] #S #[bg=%s,fg=%s]%s#[bg=%s,fg=%s] #(whoami) #[bg=%s,fg=%s]%s#[bg=%s,fg=%s,nobold] ',
    c.accent, c.bg,                    -- Section a: purple accent
    c.line_highlight, c.accent,        -- Arrow: purple on gray
    arrow_right,
    c.line_highlight, c.fg,            -- Section b: line highlight bg
    c.statusbar_bg, c.line_highlight,  -- Arrow: gray on statusbar
    arrow_right,
    c.statusbar_bg, c.statusbar_fg     -- Section c: statusbar
  )
  tmux(string.format('set-option -g status-left "%s"', status_left))
  tmux('set-option -g status-left-length 50')
  
  -- Status right: Create lualine-like sections with arrows (reverse order)
  -- Section x (statusbar_bg) -> arrow -> Section y (line_highlight) -> arrow -> Section z (purple)
  local status_right = string.format(
    '#[bg=%s,fg=%s]%s#[bg=%s,fg=%s] %%H:%%M:%%S #[bg=%s,fg=%s]%s#[bg=%s,fg=%s,bold] %%d-%%b-%%y #[fg=%s]%s#[bg=%s,fg=%s,bold] #H ',
    c.statusbar_bg, c.line_highlight,  -- Arrow into section y
    arrow_left,
    c.line_highlight, c.fg,            -- Section y: time
    c.line_highlight, c.accent,        -- Arrow into section z
    arrow_left,
    c.accent, c.bg,                    -- Section z: date
    c.accent,                          -- Arrow separator within z
    arrow_left,
    c.accent, c.bg                     -- Section z: hostname
  )
  tmux(string.format('set-option -g status-right "%s"', status_right))
  tmux('set-option -g status-right-length 80')
  
  -- Window status format with better styling
  -- Inactive windows (like lualine section c)
  tmux(string.format('set-window-option -g window-status-style "bg=%s,fg=%s"', c.statusbar_bg, c.inactive))
  
  -- Active window (like lualine section a - purple accent with dark text)
  tmux(string.format('set-window-option -g window-status-current-style "bg=%s,fg=%s,bold"', c.accent, c.bg))
  
  -- Window separator
  tmux('set-window-option -g window-status-separator ""')
  
  -- Window status format with arrows
  -- Inactive windows
  local window_format = string.format(
    '#[bg=%s,fg=%s] #I:#W #[fg=%s]',
    c.statusbar_bg, c.inactive, c.statusbar_bg
  )
  tmux(string.format('set-window-option -g window-status-format "%s"', window_format))
  
  -- Active window with arrows (purple accent)
  local window_current_format = string.format(
    '#[bg=%s,fg=%s]%s#[bg=%s,fg=%s,bold] #I:#W #[bg=%s,fg=%s]%s',
    c.accent, c.statusbar_bg,   -- Arrow into purple
    arrow_right,
    c.accent, c.bg,             -- Purple section
    c.statusbar_bg, c.accent,   -- Arrow out of purple
    arrow_right
  )
  tmux(string.format('set-window-option -g window-status-current-format "%s"', window_current_format))
  
  -- Activity and bell styles
  tmux(string.format('set-window-option -g window-status-activity-style "bg=%s,fg=%s"', c.statusbar_bg, c.accent))
  tmux(string.format('set-window-option -g window-status-bell-style "bg=%s,fg=%s"', c.statusbar_bg, c.accent))
  
  -- Pane border colors
  tmux(string.format('set-option -g pane-border-style "fg=%s"', c.border))
  tmux(string.format('set-option -g pane-active-border-style "fg=%s"', c.accent))
  
  -- Message style
  tmux(string.format('set-option -g message-style "bg=%s,fg=%s"', c.line_highlight, c.fg))
  tmux(string.format('set-option -g message-command-style "bg=%s,fg=%s"', c.line_highlight, c.fg))
  
  -- Mode style (copy mode etc)
  tmux(string.format('set-option -g mode-style "bg=%s,fg=%s"', c.accent, c.bg))
  
  -- Clock mode
  tmux(string.format('set-option -g clock-mode-colour "%s"', c.accent))
  
  -- Refresh tmux
  tmux("refresh-client -S")
end

-- Restore original tmux colors
function M.restore_status_colors()
  if not is_tmux() then
    return
  end
  
  restore_option("status-left", "MONOSPACE_STATUS_LEFT_BACKUP")
  restore_option("status-right", "MONOSPACE_STATUS_RIGHT_BACKUP")
  restore_option("status-style", "MONOSPACE_STATUS_STYLE_BACKUP")
  restore_option("status-left-length", "MONOSPACE_STATUS_LEFT_LEN_BACKUP")
  restore_option("status-right-length", "MONOSPACE_STATUS_RIGHT_LEN_BACKUP")
  restore_option("window-status-format", "MONOSPACE_WIN_FMT_BACKUP")
  restore_option("window-status-current-format", "MONOSPACE_WIN_CUR_FMT_BACKUP")
  restore_option("window-status-style", "MONOSPACE_WIN_STYLE_BACKUP")
  restore_option("window-status-current-style", "MONOSPACE_WIN_CUR_STYLE_BACKUP")
  restore_option("window-status-activity-style", "MONOSPACE_WIN_ACT_STYLE_BACKUP")
  restore_option("window-status-bell-style", "MONOSPACE_WIN_BELL_STYLE_BACKUP")
  restore_option("pane-border-style", "MONOSPACE_PANE_BORDER_BACKUP")
  restore_option("pane-active-border-style", "MONOSPACE_PANE_ACTIVE_BORDER_BACKUP")
  restore_option("message-style", "MONOSPACE_MSG_STYLE_BACKUP")
  restore_option("message-command-style", "MONOSPACE_MSG_CMD_STYLE_BACKUP")
  restore_option("mode-style", "MONOSPACE_MODE_STYLE_BACKUP")
  
  tmux("refresh-client -S")
end

-- Setup autocmds
function M.setup(variant)
  variant = variant or "dark"
  
  if not is_tmux() then
    return
  end
  
  -- Set colors when Neovim starts
  M.set_status_colors(variant)
  
  -- Restore colors when Neovim exits
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      M.restore_status_colors()
    end,
  })
  
  -- Update colors when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "monospace-*",
    callback = function()
      local bg = vim.opt.background:get()
      M.set_status_colors(bg == "light" and "light" or "dark")
    end,
  })
end

return M
