# Monospace Theme for Neovim

A minimalistic Neovim theme with subtle purple accents, ported from the [Monospace VSCode theme](https://github.com/keksiqc/monospace-theme).

## Features

- 🎨 Dark and light variants
- 🌈 Full syntax highlighting support
- 🔍 LSP diagnostics support
- 📝 Git signs support
- 🌳 Treesitter support
- 🎯 Terminal colors configured
- ⚡ Fast and lightweight

## Requirements

- Neovim 0.5.0 or higher (0.7.0+ recommended for best experience)
- Terminal with true color support (most modern terminals support this)
- `termguicolors` is automatically enabled by the theme

## Troubleshooting

### Colors look different from VSCode

The theme automatically enables `termguicolors` for true color support. If colors still look different:

1. **Check your terminal supports true color**: Most modern terminals (Alacritty, iTerm2, Kitty, etc.) support true color by default.

2. **Verify Alacritty configuration**: If using Alacritty, ensure your `alacritty.yml` has:
   ```yaml
   colors:
     # Use the terminal colors from the theme
   ```
   The theme sets terminal colors automatically, but Alacritty might override them.

3. **Check Neovim settings**: The theme sets `termguicolors` automatically. If you have it disabled elsewhere, remove that setting:
   ```lua
   -- Remove this if present:
   -- vim.opt.termguicolors = false
   ```

4. **Color differences**: Some colors in VSCode use alpha transparency that gets blended with backgrounds. The Neovim theme blends these colors appropriately, but terminal rendering may still differ slightly from VSCode's rendering engine.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

**From GitHub (when published):**
```lua
{
  "keksiqc/monospace-theme",
  lazy = false,
  priority = 1000,
  config = function()
    require("monospace").setup({
      variant = "dark", -- or "light"
    })
  end,
}
```

**Local Installation:**
```lua
{
  dir = "/path/to/monospace-theme", -- Replace with your actual path
  lazy = false,
  priority = 1000,
  config = function()
    require("monospace").setup({
      variant = "dark", -- or "light"
    })
  end,
}
```

**Example with absolute path:**
```lua
{
  dir = "/Users/tolga/_DEV/t/monospace-theme",
  lazy = false,
  priority = 1000,
  config = function()
    require("monospace").setup({
      variant = "dark",
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "keksiqc/monospace-theme",
  config = function()
    require("monospace").setup({
      variant = "dark", -- or "light"
    })
  end,
}
```

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/keksiqc/monospace-theme.git ~/.config/nvim/pack/themes/start/monospace-theme
```

2. Add to your `init.lua`:
```lua
require("monospace").setup({
  variant = "dark", -- or "light"
})
```

## Usage

### Basic Setup

```lua
-- In your init.lua or colorscheme config
require("monospace").setup({
  variant = "dark", -- Options: "dark" or "light"
})
```

### Switching Themes

You can switch themes programmatically:

```lua
-- Switch to dark theme
require("monospace").load_dark()

-- Switch to light theme
require("monospace").load_light()
```

### Using with `:colorscheme`

The theme registers itself as `monospace-dark` and `monospace-light`:

```vim
:colorscheme monospace-dark
:colorscheme monospace-light
```

## Configuration

The theme supports minimal configuration:

```lua
require("monospace").setup({
  variant = "dark", -- "dark" or "light"
})
```

## Color Palette

### Dark Theme
- Background: `#171f2b`
- Foreground: `#d9dfe7`
- Purple accent: `#a87ffb`
- Comments: `#7f8d9f`

### Light Theme
- Background: `#ffffff`
- Foreground: `#1f2939`
- Purple accent: `#6f4cde`
- Comments: `#637083`

## Plugin Support

The theme includes support for:

- **LSP**: Diagnostics, references, and code actions
- **Treesitter**: Full syntax highlighting
- **Git**: Signs and diff highlighting
- **Terminal**: ANSI color support
- **Lualine**: Built-in theme support (automatically configured)
- **Statusline**: Compatible with most statusline plugins
- **UI Panels**: Full theming for common Neovim UI plugins:
  - **NvimTree** (File Explorer) - Matches VSCode sidebar colors
  - **Telescope** (Command Palette) - Matches VSCode quick input
  - **WhichKey** - Keybinding helper
  - **Notify** - Notification system
  - **Noice** - Command line UI
  - **Bufferline** - Tab bar
  - **Indent Blankline** - Indentation guides
  - **Dashboard/Alpha** - Startup screen
  - **Popup Menus** - Dropdown menus match VSCode styling

### Lualine Integration

The theme automatically configures lualine when available. The lualine theme matches the Monospace color scheme:

```lua
require("monospace").setup({
  variant = "dark",
  setup_lualine = true, -- Default: true
})
```

**Manual lualine setup:**

If you prefer to configure lualine manually:

```lua
require("lualine").setup({
  options = {
    theme = "monospace_dark", -- or "monospace_light"
  },
})
```

**Disable auto-setup:**

```lua
require("monospace").setup({
  variant = "dark",
  setup_lualine = false, -- Disable automatic lualine configuration
})
```

### Tmux Integration

The theme can automatically change tmux status line colors when Neovim is active, matching the Monospace theme:

```lua
require("monospace").setup({
  variant = "dark",
  setup_tmux = true, -- Enable tmux status line integration
})
```

**What it does:**
- Changes tmux status line colors to match the Monospace theme when Neovim starts
- Restores original tmux colors when Neovim exits
- Updates colors automatically when switching between dark/light variants

**Manual tmux setup:**

You can also manually control tmux colors:

```lua
local tmux = require("monospace.tmux")

-- Set tmux colors
tmux.set_status_colors("dark") -- or "light"

-- Restore original colors
tmux.restore_status_colors()
```

**Note:** This feature only works when running Neovim inside a tmux session (`$TMUX` environment variable must be set).

## Screenshots

> Coming soon - screenshots will be added here

## Related

- [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=keksiqc.idx-monospace-theme)
- [Original Repository](https://github.com/keksiqc/monospace-theme)

## License

MIT License - see [LICENSE](LICENSE) file for details.

