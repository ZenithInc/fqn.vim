local M = {}

local utils = require('fqn.utils')
local lsp = require('fqn.lsp')
local languages = require('fqn.languages')

-- LSP SymbolKind values that we care about
local SYMBOL_KINDS = {
  File = 1,
  Module = 2,
  Namespace = 3,
  Package = 4,
  Class = 5,
  Method = 6,
  Property = 7,
  Field = 8,
  Constructor = 9,
  Enum = 10,
  Interface = 11,
  Function = 12,
  Variable = 13,
  Constant = 14,
  String = 15,
  Number = 16,
  Boolean = 17,
  Array = 18,
  Object = 19,
  Key = 20,
  Null = 21,
  EnumMember = 22,
  Struct = 23,
  Event = 24,
  Operator = 25,
  TypeParameter = 26,
}

-- Symbol kinds that should be included in FQN
local FQN_SYMBOL_KINDS = {
  [SYMBOL_KINDS.Module] = true,
  [SYMBOL_KINDS.Namespace] = true,
  [SYMBOL_KINDS.Package] = true,
  [SYMBOL_KINDS.Class] = true,
  [SYMBOL_KINDS.Method] = true,
  [SYMBOL_KINDS.Constructor] = true,
  [SYMBOL_KINDS.Enum] = true,
  [SYMBOL_KINDS.Interface] = true,
  [SYMBOL_KINDS.Function] = true,
  [SYMBOL_KINDS.Struct] = true,
}

---Find symbol path at cursor position (recursive)
---@param symbols table[] Document symbols
---@param line integer 1-indexed line
---@param col integer 0-indexed column
---@param path table Current path accumulator
---@return table|nil path Array of {name, kind} tables
local function find_symbol_path(symbols, line, col, path)
  if not symbols then
    return nil
  end

  for _, symbol in ipairs(symbols) do
    local range = symbol.range or (symbol.location and symbol.location.range)
    if range and utils.pos_in_range(line, col, range) then
      -- Add this symbol to path if it's a meaningful type
      if FQN_SYMBOL_KINDS[symbol.kind] then
        table.insert(path, { name = symbol.name, kind = symbol.kind })
      end

      -- Check children (DocumentSymbol format)
      if symbol.children and #symbol.children > 0 then
        local child_result = find_symbol_path(symbol.children, line, col, path)
        if child_result then
          return child_result
        end
      end

      -- If we found a symbol and it's in FQN kinds, return the path
      if FQN_SYMBOL_KINDS[symbol.kind] then
        return path
      end
    end
  end

  return #path > 0 and path or nil
end

---Get FQN for current cursor position
---@param config table Plugin configuration
---@param callback function(fqn: string|nil)
function M.get_fqn(config, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = utils.get_filetype()

  if not lsp.has_document_symbol_support(bufnr) then
    utils.notify('No LSP with documentSymbol support', vim.log.levels.WARN)
    callback(nil)
    return
  end

  local line, col = utils.get_cursor_pos()

  lsp.get_document_symbols(bufnr, function(symbols)
    if not symbols or #symbols == 0 then
      utils.notify('No symbols found', vim.log.levels.WARN)
      callback(nil)
      return
    end

    local path = find_symbol_path(symbols, line, col, {})
    if not path or #path == 0 then
      utils.notify('No symbol at cursor position', vim.log.levels.WARN)
      callback(nil)
      return
    end

    -- Build FQN using language-specific handler
    local fqn = languages.build_fqn(filetype, path, config)
    callback(fqn)
  end)
end

return M
