local M = {}

-- SymbolKind constants
M.SYMBOL_KINDS = {
  Module = 2,
  Namespace = 3,
  Package = 4,
  Class = 5,
  Method = 6,
  Constructor = 9,
  Enum = 10,
  Interface = 11,
  Function = 12,
  Struct = 23,
}

M.filetypes = { 'php' }

M.default_config = {
  namespace_separator = '\\',
  method_separator = '::',
  include_parens = true,
}

---Build FQN for PHP
---@param path table[] Array of {name, kind}
---@param config table Language config
---@return string
function M.build_fqn(path, config)
  local cfg = vim.tbl_deep_extend('force', M.default_config, config or {})
  local parts = {}
  local last_class_idx = 0

  -- Find the last class/interface/trait in the path
  for i, item in ipairs(path) do
    if item.kind == M.SYMBOL_KINDS.Class
        or item.kind == M.SYMBOL_KINDS.Interface
        or item.kind == M.SYMBOL_KINDS.Enum then
      last_class_idx = i
    end
  end

  for i, item in ipairs(path) do
    local name = item.name

    if i == 1 then
      table.insert(parts, name)
    elseif i <= last_class_idx then
      -- Namespace or class hierarchy
      table.insert(parts, cfg.namespace_separator .. name)
    else
      -- Method/function after class
      table.insert(parts, cfg.method_separator .. name)
    end
  end

  local result = table.concat(parts, '')

  -- Add parentheses for methods/functions
  if cfg.include_parens then
    local last = path[#path]
    if last and (last.kind == M.SYMBOL_KINDS.Method
        or last.kind == M.SYMBOL_KINDS.Function
        or last.kind == M.SYMBOL_KINDS.Constructor) then
      result = result .. '()'
    end
  end

  return result
end

return M
