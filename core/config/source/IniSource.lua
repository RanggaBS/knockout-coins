-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local BaseSource = KNOCKOUT_COINS.Class.BaseSource

-- -------------------------------------------------------------------------- --
-- IniSource Class                                                            --
-- -------------------------------------------------------------------------- --

---@class IniSource : BaseSource
---@field path string
---@field filename string
---@field object userdata
local IniSource = setmetatable({}, { __index = BaseSource })
IniSource.__index = IniSource

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param path string
---@param filename string
---@return IniSource
function IniSource.new(path, filename)
  local instance = BaseSource.new(path, filename)
  instance = setmetatable(instance, IniSource)
  return instance --[[@as IniSource]]
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

function IniSource:Load()
  local fullPath = self.path .. self.filename
  local object = LoadConfigFile(fullPath)
  if IsConfigMissing(object) then
    return error('Cannot load ini: ' .. fullPath)
  end
  self.object = object
end

---@param key string
---@param defaultValue Config_Value
function IniSource:Get(key, defaultValue)
  local getter = ({
    ['boolean'] = GetConfigBoolean,
    ['number'] = GetConfigNumber,
    ['string'] = GetConfigString,
  })[type(defaultValue)] or GetConfigValue
  return getter(self.object, key, defaultValue) or defaultValue
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.IniSource = IniSource
