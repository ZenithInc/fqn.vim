local M = {}

---Copy text to system clipboard
---@param text string
function M.copy_to_clipboard(text)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
end

---Show notification message
---@param msg string
---@param level? integer vim.log.levels.*
function M.notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level, { title = 'fqn.nvim' })
end

---Get cursor position (1-indexed line, 0-indexed col)
---@return integer line
---@return integer col
function M.get_cursor_pos()
  local pos = vim.api.nvim_win_get_cursor(0)
  return pos[1], pos[2]
end

---Check if position is within range
---@param line integer 1-indexed line number
---@param col integer 0-indexed column number
---@param range table LSP range object
---@return boolean
function M.pos_in_range(line, col, range)
  local start_line = range.start.line + 1 -- LSP is 0-indexed
  local end_line = range['end'].line + 1
  local start_col = range.start.character
  local end_col = range['end'].character

  if line < start_line or line > end_line then
    return false
  end

  if line == start_line and col < start_col then
    return false
  end

  if line == end_line and col >= end_col then
    return false
  end

  return true
end

---Get current buffer filetype
---@return string
function M.get_filetype()
  return vim.bo.filetype
end

return M
