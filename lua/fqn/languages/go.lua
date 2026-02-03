local M = {}

M.SYMBOL_KINDS = {
  Package = 4,
  Struct = 23,
  Interface = 11,
  Function = 12,
  Method = 6,
}

M.filetypes = { 'go' }

M.default_config = {
  separator = '.',
  include_parens = false,
}

---Build FQN for Go
---@param path table[] Array of {name, kind}
---@param config table Language config
---@return string
function M.build_fqn(path, config)
  local cfg = vim.tbl_deep_extend('force', M.default_config, config or {})
  local names = {}

  for _, item in ipairs(path) do
    table.insert(names, item.name)
  end

  return table.concat(names, cfg.separator)
end

return M
