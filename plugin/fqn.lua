-- fqn.nvim plugin entry point
-- Lazy-load the main module when commands/keymaps are used

vim.api.nvim_create_user_command('FqnCopy', function()
  require('fqn').copy()
end, { desc = 'Copy Fully Qualified Name to clipboard' })
