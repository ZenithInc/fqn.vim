local M = {}

local utils = require('fqn.utils')

---Request document symbols from LSP
---@param bufnr integer
---@param callback function(symbols: table|nil)
function M.get_document_symbols(bufnr, callback)
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  vim.lsp.buf_request(bufnr, 'textDocument/documentSymbol', params, function(err, result)
    if err then
      utils.notify('LSP error: ' .. (err.message or 'unknown error'), vim.log.levels.ERROR)
      callback(nil)
      return
    end
    callback(result)
  end)
end

---Check if any LSP client supports documentSymbol
---@param bufnr integer
---@return boolean
function M.has_document_symbol_support(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.server_capabilities.documentSymbolProvider then
      return true
    end
  end
  return false
end

return M
