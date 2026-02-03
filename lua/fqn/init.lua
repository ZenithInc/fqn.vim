local M = {}

local core = require('fqn.core')
local utils = require('fqn.utils')
local languages = require('fqn.languages')

-- Default configuration
M.config = {
  -- Keymap to copy FQN (set to false to disable)
  keymap = '<leader>fy',

  -- Show notification after copying
  notify = true,

  -- Language-specific settings
  languages = {},
}

---Setup the plugin
---@param opts table|nil User configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Create user command
  vim.api.nvim_create_user_command('FqnCopy', function()
    M.copy()
  end, { desc = 'Copy Fully Qualified Name to clipboard' })

  -- Set up keymap if configured
  if M.config.keymap then
    vim.keymap.set('n', M.config.keymap, function()
      M.copy()
    end, { desc = 'Copy FQN to clipboard', silent = true })
  end
end

---Copy FQN to clipboard
function M.copy()
  core.get_fqn(M.config, function(fqn)
    if fqn then
      utils.copy_to_clipboard(fqn)
      if M.config.notify then
        utils.notify('Copied: ' .. fqn)
      end
    end
  end)
end

---Get FQN as string (async, returns via callback)
---@param callback function(fqn: string|nil)
function M.get(callback)
  core.get_fqn(M.config, callback)
end

---Register a custom language handler
---@param name string Language name
---@param handler table Handler configuration
function M.register_language(name, handler)
  languages.register(name, handler)
end

return M
