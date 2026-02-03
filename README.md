# fqn.nvim

A Neovim plugin to copy the Fully Qualified Name (FQN) of the symbol under cursor to clipboard.

Similar to the "Copy Reference" feature in JetBrains IDEs (PHPStorm, IntelliJ, etc.).

## Features

- 📋 Copy fully qualified method/function/class names to clipboard
- 🌍 Multi-language support via LSP (PHP, Python, Rust, Go, TypeScript)
- 🔧 Language-aware separators (e.g., `\` for PHP namespaces, `::` for Rust)
- 📢 Optional notification on copy
- ⌨️ Customizable keymaps

## Requirements

- Neovim >= 0.8.0
- A working LSP server for your language

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'your-username/fqn.nvim',
  config = function()
    require('fqn').setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'your-username/fqn.nvim',
  config = function()
    require('fqn').setup()
  end,
}
```

## Configuration

```lua
require('fqn').setup({
  -- Keymap to copy FQN (set to false to disable)
  keymap = '<leader>fy',

  -- Show notification after copying
  notify = true,

  -- Language-specific settings (optional, these are defaults)
  languages = {
    php = {
      namespace_separator = '\\',
      method_separator = '::',
    },
    python = {
      separator = '.',
    },
    rust = {
      separator = '::',
    },
    go = {
      separator = '.',
    },
    typescript = {
      separator = '.',
    },
  },
})
```

## Usage

### Commands

- `:FqnCopy` - Copy the FQN of the symbol under cursor

### Lua API

```lua
-- Copy FQN to clipboard and show notification
require('fqn').copy()

-- Get FQN as string (without copying)
local fqn = require('fqn').get()
```

### Default Keymap

- `<leader>fy` - Copy FQN (mnemonic: "fully qualified yank")

## Examples

| Language   | Symbol Location                     | Result                              |
|------------|-------------------------------------|-------------------------------------|
| PHP        | Method `save` in `App\User`         | `App\User::save()`                  |
| Python     | Method `run` in `myapp.tasks.Task`  | `myapp.tasks.Task.run`              |
| Rust       | Function `parse` in `crate::parser` | `crate::parser::parse`              |
| Go         | Method `Run` in `pkg.Service`       | `pkg.Service.Run`                   |
| TypeScript | Method `fetch` in `api.Client`      | `api.Client.fetch`                  |

## How It Works

1. Queries the LSP server for document symbols (`textDocument/documentSymbol`)
2. Finds the symbol hierarchy at the cursor position
3. Builds the FQN using language-specific separators
4. Copies to system clipboard and optionally shows a notification

## Supported Languages

| Language   | LSP Server                | Status |
|------------|---------------------------|--------|
| PHP        | intelephense / phpactor   | ✅     |
| Python     | pyright / pylsp           | ✅     |
| Rust       | rust-analyzer             | ✅     |
| Go         | gopls                     | ✅     |
| TypeScript | typescript-language-server| ✅     |

## Adding New Language Support

Create a new file in `lua/fqn/languages/` following this template:

```lua
local M = {}

M.filetypes = { 'yourlang' }

M.config = {
  separator = '.',
}

function M.build_fqn(symbols, config)
  -- Custom FQN building logic
  return table.concat(symbols, config.separator)
end

return M
```

Then register it in `lua/fqn/languages/init.lua`.

## License

MIT
