-- -------------------------------------------------------------------------- --
-- BaseSource Class                                                           --
-- -------------------------------------------------------------------------- --

---@class BaseSource
---@field path string
---@field filename string
local BaseSource = {}
BaseSource.__index = BaseSource

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param path string
---@param filename string
---@return BaseSource
function BaseSource.new(path, filename)
  local instance = setmetatable({}, BaseSource)
  instance.path = path
  instance.filename = filename
  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

-- Abstract: Load config data
function BaseSource:Load()
  -- Nothing. Must be implemented by subclass.
end

-- Abstract: Get config value
function BaseSource:Get(key, defaultValue)
  -- Nothing. Must be implemented by subclass.
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.BaseSource = BaseSource
