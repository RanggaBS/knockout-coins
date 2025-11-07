-- -------------------------------------------------------------------------- --
-- Config Class                                                               --
-- -------------------------------------------------------------------------- --

---@class Config
---@field object userdata?
---@field defaultSettings table<string, Config_Value>
---@field settings table<string, Config_Value>
---@field configSource IniSource|LuaSource
local Config = {}
Config.__index = Config

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param defaultSettings table<string, Config_Value>
---@param configSource IniSource|LuaSource
---@return Config
function Config.new(defaultSettings, configSource)
  local instance = setmetatable({}, Config)

  instance.defaultSettings = defaultSettings
  instance.settings = {}
  instance.configSource = configSource

  instance:Load()

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

function Config:Load()
  self.configSource:Load()

  for key, defaultValue in pairs(self.defaultSettings) do
    self.settings[key] = self.configSource:Get(key, defaultValue)
  end
end

---@param key string
---@param fallbackValue? Config_Value
---@return Config_Value
function Config:Get(key, fallbackValue)
  return self.settings[key] or fallbackValue or self.defaultSettings[key]
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.Config = Config

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias Config_Value boolean|number|string
