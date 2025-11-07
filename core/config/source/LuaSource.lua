-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local Util = KNOCKOUT_COINS.Util
local BaseSource = KNOCKOUT_COINS.Class.BaseSource

-- -------------------------------------------------------------------------- --
-- LuaSource Class                                                            --
-- -------------------------------------------------------------------------- --

---@class LuaSource : BaseSource
---@field path string
---@field filename string
---@field data table<string, Config_Value>
local LuaSource = setmetatable({}, { __index = BaseSource })
LuaSource.__index = LuaSource

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param path string
---@param filename string
---@param data table<string, Config_Value>
---@return LuaSource
function LuaSource.new(path, filename, data)
  local instance = BaseSource.new(path, filename)
  instance = setmetatable(instance, LuaSource)

  instance.data = data

  return instance --[[@as LuaSource]]
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

function LuaSource:Load()
  if Util.GetGameEdition() ~= 'AE' then return end

  local ok = Util.AELoadScript(self.path, self.filename)
  if ok then
    KNOCKOUT_COINS.AE_isConfigLoaded = true
    KNOCKOUT_COINS.AE_isWarningMessageDisplayed = false
    return
  end

  SoundPlay2D('Erand')
  MinigameSetAnnouncement('Knockout Coins WARNING', true)
  MinigameHoldCompletion()
  Wait(2000)

  MinigameSetAnnouncement('Failed to load config\n' .. self.filename, true)
  MinigameHoldCompletion()
  Wait(2000)

  MinigameSetAnnouncement('Using default configuration\n', true)
  MinigameHoldCompletion()
  Wait(2000)

  MinigameReleaseCompletion()
  KNOCKOUT_COINS.AE_isWarningMessageDisplayed = false
end

---@param key string
---@param defaultValue Config_Value
---@return Config_Value
function LuaSource:Get(key, defaultValue)
  local value = self.data[key]
  if value == nil or type(value) ~= type(defaultValue) then
    return defaultValue
  end
  return value
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.LuaSource = LuaSource
