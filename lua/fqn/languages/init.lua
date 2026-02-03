local M = {}

-- Language handlers registry
local handlers = {
  php = require('fqn.languages.php'),
  python = require('fqn.languages.python'),
  rust = require('fqn.languages.rust'),
  go = require('fqn.languages.go'),
  typescript = require('fqn.languages.typescript'),
}

-- Filetype to handler mapping
local filetype_map = {}

-- Build filetype map from handlers
for lang, handler in pairs(handlers) do
  if handler.filetypes then
    for _, ft in ipairs(handler.filetypes) do
      filetype_map[ft] = lang
    end
  end
end

---Get handler for a filetype
---@param filetype string
---@return table|nil handler
---@return string|nil lang_name
function M.get_handler(filetype)
  local lang = filetype_map[filetype]
  if lang then
    return handlers[lang], lang
  end
  return nil, nil
end

---Build FQN using appropriate language handler
---@param filetype string
---@param path table[] Array of {name, kind}
---@param config table Plugin config
---@return string
function M.build_fqn(filetype, path, config)
  local handler, lang = M.get_handler(filetype)

  if handler and handler.build_fqn then
    local lang_config = config.languages and config.languages[lang] or {}
    return handler.build_fqn(path, lang_config)
  end

  -- Default: join with '.'
  local names = {}
  for _, item in ipairs(path) do
    table.insert(names, item.name)
  end
  return table.concat(names, '.')
end

---Register a custom language handler
---@param name string Language name
---@param handler table Handler with filetypes, default_config, build_fqn
function M.register(name, handler)
  handlers[name] = handler
  if handler.filetypes then
    for _, ft in ipairs(handler.filetypes) do
      filetype_map[ft] = name
    end
  end
end

---Get list of supported filetypes
---@return string[]
function M.get_supported_filetypes()
  local filetypes = {}
  for ft, _ in pairs(filetype_map) do
    table.insert(filetypes, ft)
  end
  return filetypes
end

return M
