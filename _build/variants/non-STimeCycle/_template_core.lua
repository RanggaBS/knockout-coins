-- -------------------------------------------------------------------------- --
-- File: init.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Mod root global variable                                                   --
-- -------------------------------------------------------------------------- --

_G.KNOCKOUT_COINS = {
  API = {},
  Enum = {},
  Class = {},
  Instance = {},
  Util = {},
  Thread = {},
  DefaultSettings = {},

  -- Bully AE user configurations, `nil` by default
  ---@type table<string, boolean|number|string>?
  Config = nil,

  ConfigData = {
    SE = {
      path = 'config/',
      file = 'config_se.ini',
    },
    AE = {
      path = '/storage/emulated/0/Games/BullyAE/Mods/KnockoutCoins/config/',
      file = 'config_ae.lur',
    },
  },
  AE_isConfigLoaded = false,
  AE_isWarningMessageDisplayed = true,
}

-- -------------------------------------------------------------------------- --
-- Load scripts                                                               --
-- -------------------------------------------------------------------------- --

local isBullySE = type(_G.ClassMusicSetPlayers) == 'function'
  and type(_G.PlayerGetUsingTouchScreen) ~= 'function'

if isBullySE then
  local files = {
    { name = 'Util', dir = 'utils/' },
    { name = '_group', dir = 'enums/' },

    { name = 'BaseSource', dir = 'core/config/source/' },
    { name = 'IniSource', dir = 'core/config/source/' },
    { name = 'LuaSource', dir = 'core/config/source/' },
    { name = 'Config', dir = 'core/config/' },

    { name = 'ObjectEntity', dir = 'core/objects/' },
    { name = 'PickupSpeech', dir = 'core/objects/pickup/' },
    { name = 'BasePickup', dir = 'core/objects/pickup/' },
    { name = 'CoinPickup', dir = 'core/objects/pickup/' },
    { name = 'PickupManager', dir = 'core/objects/pickup/' },

    { name = 'Coin', dir = 'core/coins/' },
    { name = 'CoinDropManager', dir = 'core/coins/' },

    { name = 'PedKnockedOut', dir = 'core/threads/' },
    { name = 'ThreadManager', dir = 'core/threads/' },

    { name = 'EventManager', dir = 'core/' },
    { name = 'KnockoutCoins', dir = 'core/' },
  }
  for _, file in ipairs(files) do
    LoadScript(file.dir .. file.name .. '.lua')
  end
end

-- -------------------------------------------------------------------------- --
-- Default Settings                                                           --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.DefaultSettings = {
  -- [Coin Values]
  -- ------------------------------------------------------------------------ --
  -- Defines how much money each coin gives when collected.
  -- The game uses "cents" internally. (100 = $1.00)
  -- Example:
  --   25  = +$0.25
  --   100 = +$1.00
  -- ------------------------------------------------------------------------ --
  CoinPenny = 25, -- small gold coin (common)
  CoinDollar = 100, -- large silver coin (rare)

  -- [Coin Settings]
  -- ---------------------------------------------------------------------------- --
  -- Controls how coins behave after a ped is knocked out.
  -- ---------------------------------------------------------------------------- --

  -- Base chance (in percent) for *any* coin to drop.
  -- Individual coin chances are multiplied by this value.
  GlobalDropChance = 75,

  -- How close the player must be to automatically pick up a coin.
  PickupRadius = 1.25,

  -- Determines how long coins stay in the world before disappearing.
  --   0 = Time-based (coins vanish after `LifetimeSeconds`)
  --   1 = Ped-based (coins stay until the KO'd ped fades out)
  --   2 = Hybrid (stay while ped exists, then a short timer starts)
  LifetimeMode = 2,

  -- Duration (in seconds) coins remain if `LifetimeMode` = 0 or 2.
  LifetimeSeconds = 30,

  -- [Coin Type Chance]
  -- ---------------------------------------------------------------------------- --
  -- Defines individual drop chances for each coin type (percent).
  -- These chances are evaluated only if `GlobalDropChance` is passed.
  -- Example:
  --   CoinPennyChance = 80  -> 80% chance if a drop occurs
  --   CoinDollarChance = 20 -> 20% chance if a drop occurs
  -- ---------------------------------------------------------------------------- --
  CoinPennyChance = 80,
  CoinDollarChance = 20,

  -- [Coin Animation]
  -- ---------------------------------------------------------------------------- --
  -- Controls the visual animation and motion of dropped coins.
  -- ---------------------------------------------------------------------------- --

  -- Determines how high the coin bobs up and down.
  -- Default: 1
  BobAmplitude = 1,

  -- Determines how fast the coin bobs up and down.
  -- Higher values make it oscillate faster.
  -- Default: 3
  BobFrequency = 3,

  -- Determines how fast the coin spins in degrees per second.
  -- Default: 60
  RotationSpeed = 60,

  -- If true, each coin will spin in a random direction (clockwise or counterclockwise).
  -- If false, all coins spin the same direction.
  -- Default: true
  RandomRotationDirection = true,

  -- If true, all coins bob in sync (move up and down together).
  -- If false, each coin has a random phase offset.
  -- Default: false
  BobSync = false,

  -- [Faction Drop Amount]
  -- ---------------------------------------------------------------------------- --
  -- Defines how many coins each faction may drop when knocked out.
  -- The final number can be randomized between Min and Max.
  -- Example: NerdMin = 1, NerdMax = 3 → drop 1–3 coins randomly.
  -- ---------------------------------------------------------------------------- --

  PrefectMin = 1,
  PrefectMax = 2,

  NerdMin = 1,
  NerdMax = 2,

  JockMin = 1,
  JockMax = 2,

  DropoutMin = 1,
  DropoutMax = 2,

  GreaserMin = 1,
  GreaserMax = 2,

  PreppyMin = 2,
  PreppyMax = 4,

  StudentMin = 1,
  StudentMax = 2,

  CopMin = 1,
  CopMax = 3,

  TeacherMin = 1,
  TeacherMax = 3,

  TownpersonMin = 1,
  TownpersonMax = 3,

  ShopkeepMin = 1,
  ShopkeepMax = 4,

  BullyMin = 1,
  BullyMax = 2,
}

-- -------------------------------------------------------------------------- --
-- File: utils/Util.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Utility / Helper Functions                                                 --
-- -------------------------------------------------------------------------- --

local Util = {
  gameEdition = nil, ---@type 'AE'|'SE'|'PS2
  isBullyAE = nil, ---@type boolean
}

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@return 'AE'|'SE'|'PS2
function Util.GetGameEdition()
  if Util.gameEdition == nil then
    Util.gameEdition = type(_G.PlayerGetUsingTouchScreen) == 'function' and 'AE'
      or type(_G.ClassMusicSetPlayers) == 'function' and 'SE'
      or 'PS2'
  end
  return Util.gameEdition
end

---@param path string
---@param fileName string
---@param required? boolean
---@return boolean loaded
function Util.AELoadScript(path, fileName, required)
  local chunk, errorMessage = loadfile(path .. fileName)
  if not chunk then
    if required then
      while true do
        Wait(0)
        MinigameSetAnnouncement('Cannot read or missing\n' .. fileName, true)
      end
    end
    return false
  end
  chunk()
  return true
end

---@return fun(): integer
function Util.AllPeds()
  if Util.GetGameEdition() == 'SE' then return AllPeds end

  local peds = { PedFindInAreaXYZ(0, 0, 0, 99999) }
  local index = 0
  local count = table.getn(peds)

  return function()
    index = index + 1
    while index <= count do
      local ped = peds[index]
      if PedIsValid(ped) then return ped end
      index = index + 1
    end --[[@diagnostic disable-line]]
  end
end

---@param n number
---@param mult? number # default `1`
---@return number
function Util.RoundToMultiple(n, mult)
  mult = mult or 1
  return math.floor((n + mult / 2) / mult) * mult
end

---@param v number
---@param min number
---@param max number
---@return number
function Util.Clamp(v, min, max)
  return v < min and min or v > max and max or v
end

---@param cents number
---@return string
function Util.CentsToString(cents)
  local dollars = cents / 100
  return string.format('+$%.2f', dollars)
end

---@param chance number
---@return boolean
function Util.PercentChance(chance)
  return (math.random() * 100) <= chance
end

---@param dividend number
---@param divisor number
---@return number
function Util.Modulus(dividend, divisor)
  return dividend - divisor * math.floor(dividend / divisor)
end

---@param word string
---@return string
function Util.CapitalizeFirstLetter(word)
  return string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2, -1)
end

---@param factionId integer
---@return string|'Unknown'
function Util.GetFactionName(factionId)
  local names = {
    [0] = 'Prefect',
    [1] = 'Nerd',
    [2] = 'Jock',
    [3] = 'Dropout',
    [4] = 'Greaser',
    [5] = 'Preppy',
    [6] = 'Student',
    [7] = 'Cop',
    [8] = 'Teacher',
    [9] = 'Townperson',
    [10] = 'Shopkeep',
    [11] = 'Bully',
  }
  return names[factionId] or 'Unknown'
end

---@param a number
---@param b number
---@param t number
---@return number
function Util.Lerp(a, b, t)
  return a == b and a or t == 0 and a or t == 1 and b or a + (b - a) * t
end

---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param factor number
---@return number x, number y, number z
function Util.LerpBetweenCoords3d(x1, y1, z1, x2, y2, z2, factor)
  local x = Util.Lerp(x1, x2, factor)
  local y = Util.Lerp(y1, y2, factor)
  local z = Util.Lerp(z1, z2, factor)
  return x, y, z
end

---@param min number
---@param max number
---@return number
function Util.RandomFloatInclusive(min, max)
  return min + (math.random() * (max - min))
end

---@param ped integer
---@return integer|-1
function Util.GetPedModelId(ped)
  for id = 0, 258 do
    if PedIsModel(ped, id) then return id end
  end
  return -1
end

---@param ped integer
---@return boolean
function Util.IsPedHumanoid(ped)
  for _, id in ipairs({ -- non-human models
    136, -- rat
    141, -- pitbull
    219, -- pitbull 2
    220, -- pitbull 3
    233, -- punching bag
  }) do
    if PedIsModel(ped, id) or Util.GetPedModelId(ped) == id then
      return false
    end
  end
  return true
end

-- function Util.PlayPickupMoneyVoiceForJimmy() end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Util = Util

-- -------------------------------------------------------------------------- --
-- File: enums/Event.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Event Enumeration                                                          --
-- -------------------------------------------------------------------------- --

---@enum EEvent
local Event = {
  AllCoinsCleared = 'AllCoinsCleared',
  CoinBatchSpawned = 'CoinBatchSpawned',
  CoinCollected = 'CoinCollected',
  CoinDropFailed = 'CoinDropFailed',
  CoinExpired = 'CoinExpired',
  CoinRemoved = 'CoinRemoved',
  CoinSpawned = 'CoinSpawned',
  PedKnockedOut = 'PedKnockedOut',

  BeforeCoinUpdate = 'BeforeCoinUpdate',
  AfterCoinUpdate = 'AfterCoinUpdate',

  BeforeCoinUpdateAll = 'BeforeCoinUpdateAll',
  AfterCoinUpdateAll = 'AfterCoinUpdateAll',
}

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Enum.Event = Event

-- -------------------------------------------------------------------------- --
-- File: enums/_group.lua
-- -------------------------------------------------------------------------- --
local Util = KNOCKOUT_COINS.Util;

(function()
  if Util.GetGameEdition() ~= 'SE' then return end

  local filenames = { 'Event' }
  for _, filename in ipairs(filenames) do
    LoadScript('enums/' .. filename .. '.lua')
  end
end)()

-- -------------------------------------------------------------------------- --
-- File: core/config/source/BaseSource.lua
-- -------------------------------------------------------------------------- --
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

-- -------------------------------------------------------------------------- --
-- File: core/config/source/IniSource.lua
-- -------------------------------------------------------------------------- --
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

-- -------------------------------------------------------------------------- --
-- File: core/config/source/LuaSource.lua
-- -------------------------------------------------------------------------- --
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

-- -------------------------------------------------------------------------- --
-- File: core/config/Config.lua
-- -------------------------------------------------------------------------- --
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

-- -------------------------------------------------------------------------- --
-- File: core/objects/ObjectEntity.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- ObjectEntity class                                                         --
-- -------------------------------------------------------------------------- --

---@class ObjectEntity
---@field name string
---@field index integer
---@field pool integer
---@field pos ArrayOfNumbers3D
---@field area integer
---@field rotation number
local ObjectEntity = {}
ObjectEntity.__index = ObjectEntity

---Create a new persistent entity in the world.
---@param name string
---@param x? number
---@param y? number
---@param z? number
---@param area? integer
---@param rotation? number
function ObjectEntity.new(name, x, y, z, area, rotation)
  local self = setmetatable({}, ObjectEntity)

  self.name = name
  self.pos = { x or 0, y or 0, z or 0 }
  self.area = area or AreaGetVisible()
  self.rotation = rotation or 0

  self.index, self.pool = CreatePersistentEntity(
    name,
    self.pos[1],
    self.pos[2],
    self.pos[3],
    self.area,
    self.rotation
  )

  return self
end

---Internal helper to recreate the entity.
---@return ObjectEntity
function ObjectEntity:Recreate()
  -- Delete the old one
  if self.index and self.pool then
    DeletePersistentEntity(self.index, self.pool)
  end
  -- Recreate
  self.index, self.pool = CreatePersistentEntity(
    self.name,
    self.pos[1],
    self.pos[2],
    self.pos[3],
    self.rotation,
    self.area
  )
  return self
end

---Set a new rotation (in degrees)
---@param deg? number
---@return ObjectEntity
function ObjectEntity:SetRotation(deg)
  if self.rotation == deg then return self end
  self.rotation = deg or self.rotation
  return self:Recreate()
end

---Set a new position (x, y, z)
---@param x? number
---@param y? number
---@param z? number
---@return ObjectEntity
function ObjectEntity:SetPosition(x, y, z)
  if self.pos[1] == x and self.pos[2] == y and self.pos[3] == z then
    return self
  end
  self.pos[1] = x or self.pos[1]
  self.pos[2] = y or self.pos[2]
  self.pos[3] = z or self.pos[3]
  return self:Recreate()
end

---Destroy this entity from the world
---@return boolean success
function ObjectEntity:Destroy()
  if not self.index or not self.pool then return false end
  DeletePersistentEntity(self.index, self.pool)
  self.index, self.pool = nil, nil
  return true
end

---Check if this entity still exists in the world
---@return boolean
function ObjectEntity:IsExist()
  return self.index ~= nil and self.pool ~= nil
end

---@return string
function ObjectEntity:GetName()
  return self.name
end

---@return number x, number y, number z
function ObjectEntity:GetPosition()
  return self.pos[1], self.pos[2], self.pos[3]
end

---@return integer
function ObjectEntity:GetArea()
  return self.area
end

---@return number
function ObjectEntity:GetRotation()
  return self.rotation
end

---@return integer index, integer pool
function ObjectEntity:GetIndexAndPool()
  return self.index, self.pool
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.ObjectEntity = ObjectEntity

-- -------------------------------------------------------------------------- --
-- File: core/objects/pickup/PickupSpeech.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- PickupSpeech Class                                                         --
-- -------------------------------------------------------------------------- --

---@class PickupSpeech
---@field private _lastPlayTime number
---@field private _cooldown number
local PickupSpeech = {
  _lastPlayTime = 0,
  _cooldown = 3000, -- in milliseconds
}

-- -------------------------------------------------------------------------- --
-- Static Methods                                                             --
-- -------------------------------------------------------------------------- --

---@return boolean
function PickupSpeech.CanPlaySpeech()
  local JIMMY_MODEL_ID = 0
  if not PedIsModel(gPlayer, JIMMY_MODEL_ID) then return false end

  local self = PickupSpeech

  local now = GetTimer()
  if now - self._lastPlayTime < self._cooldown then return false end
  self._lastPlayTime = now

  return true
end

---@param speechName string
function PickupSpeech.Play(speechName)
  local self = PickupSpeech
  if not self.CanPlaySpeech() then return end
  if SoundSpeechPlaying(gPlayer) then SoundStopCurrentSpeechEvent(gPlayer) end
  SoundPlayAmbientSpeechEvent(gPlayer, speechName)
end

function PickupSpeech.PlayMoney()
  local self = PickupSpeech
  self.Play('PLAYER_GET_MONEY')
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.PickupSpeech = PickupSpeech

-- -------------------------------------------------------------------------- --
-- File: core/objects/pickup/BasePickup.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- BasePickup Class                                                           --
-- -------------------------------------------------------------------------- --

---@class BasePickup
---@field type string
---@field entity ObjectEntity
---@field radius number
---@field isCollected boolean
---@field lifetime number # in milliseconds
---@field lifetimeMode 0|1|2
---@field spawnTime number
---@field koTime number
---@field ped integer?
local BasePickup = {}
BasePickup.__index = BasePickup

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param entity ObjectEntity
---@param radius? number
---@param lifetime? number
---@param ped? integer
---@return BasePickup
function BasePickup.new(entity, radius, lifetime, ped)
  local instance = setmetatable({}, BasePickup)
  instance.entity = entity
  instance.radius = radius or 1.0
  instance.isCollected = false
  instance.lifetime = lifetime or (30 * 1000)
  instance.lifetimeMode = 0 -- default: time-based
  instance.spawnTime = GetTimer()
  instance.koTime = nil
  instance.ped = ped
  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

function BasePickup:OnPickup()
  -- Override in subclass
end

function BasePickup:Update()
  -- Override in subclass
end

---@return string
function BasePickup:GetType()
  return self.type
end

---@return boolean
function BasePickup:IsCollected()
  return self.isCollected
end

---@param set boolean
function BasePickup:SetCollected(set)
  self.isCollected = set
end

---@return boolean
function BasePickup:IsExist()
  return self.entity:IsExist()
end

---@return ObjectEntity
function BasePickup:GetEntity()
  return self.entity
end

---@param entity ObjectEntity
function BasePickup:SetEntity(entity)
  self.entity = entity
end

---@return number x, number y, number z
function BasePickup:GetPosition()
  return self.entity:GetPosition()
end

---@return number
function BasePickup:GetRadius()
  return self.radius
end

---@return boolean success
function BasePickup:Destroy()
  return self.entity:Destroy()
end

---@return Pickup_LifetimeModeEnum
function BasePickup:GetLifetimeMode()
  return self.lifetimeMode
end

---@param mode Pickup_LifetimeModeEnum
function BasePickup:SetLifetimeMode(mode)
  self.lifetimeMode = mode
end

---@return number
function BasePickup:GetLifetime()
  return self.lifetime
end

---@param lifetime number
function BasePickup:SetLifetime(lifetime)
  self.lifetime = lifetime
end

---@return number
function BasePickup:GetSpawnTime()
  return self.spawnTime
end

---@return number
function BasePickup:GetAge()
  return GetTimer() - self.spawnTime
end

---@return integer?
function BasePickup:GetPed()
  return self.ped
end

---@param ped integer?
function BasePickup:SetPed(ped)
  self.ped = ped
end

---@return number?
function BasePickup:GetKOTime()
  return self.koTime
end

---@param time number
function BasePickup:SetKOTime(time)
  self.koTime = time
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.BasePickup = BasePickup

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias Pickup_LifetimeMode 'time-based'|'ped-based'|'hybrid'
---@alias Pickup_LifetimeModeEnum 0|1|2

-- -------------------------------------------------------------------------- --
-- File: core/objects/pickup/CoinPickup.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local Default = KNOCKOUT_COINS.DefaultSettings
local Util = KNOCKOUT_COINS.Util
local BasePickup = KNOCKOUT_COINS.Class.BasePickup
local PickupSpeech = KNOCKOUT_COINS.Class.PickupSpeech

-- -------------------------------------------------------------------------- --
-- CoinPickup Class                                                           --
-- -------------------------------------------------------------------------- --

---@class CoinPickup : BasePickup
---@field type 'coin'
---@field radius number
---@field entity ObjectEntity
---@field coin Coin
---@field bobAmplitude number
---@field bobFrequency number
---@field rotationDirection -1|1
---@field rotationSpeed number
---@field randomOffset number
---@field lifetime number # set as fixed `number`, non/never `nil`
local CoinPickup = setmetatable({}, { __index = BasePickup })
CoinPickup.__index = CoinPickup

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param entity ObjectEntity
---@param coin Coin
---@param ped integer
---@return CoinPickup
function CoinPickup.new(entity, coin, ped)
  local config = KNOCKOUT_COINS.GetSingleton():GetConfig()
  local radius = config:Get('PickupRadius', Default.PickupRadius) --[[@as number]]

  local instance = BasePickup.new(entity, radius, nil, ped)
  instance = setmetatable(instance, CoinPickup) --[[@as CoinPickup]]

  instance.coin = coin
  instance.radius = radius
  instance.type = 'coin'
  instance:SetEntity(entity)
  instance:SetPed(ped)

  local amplitude = config:Get('BobAmplitude', Default.BobAmplitude) --[[@as number]]
  local frequency = config:Get('BobFrequency', Default.BobFrequency) --[[@as number]]
  local rotationSpeed = config:Get('RotationSpeed', Default.RotationSpeed) --[[@as number]]
  local useBobSync = config:Get('BobSync', Default.BobSync) --[[@as boolean]]
  local useRandomDirection =
    config:Get('RandomRotationDirection', Default.RandomRotationDirection) --[[@as boolean]]

  instance.bobAmplitude = amplitude * 0.01
  instance.bobFrequency = frequency
  instance.randomOffset = useBobSync and 0 or (math.random() * math.pi * 2)
  instance.rotationSpeed = rotationSpeed
  instance.rotationDirection = useRandomDirection
      and (math.random(2) == 1 and -1 or 1)
    or 1

  local lifetimeMode = config:Get('LifetimeMode', Default.LifetimeMode) --[[@as Pickup_LifetimeModeEnum]] -- 2: hybrid
  local lifetime = config:Get('LifetimeSeconds', Default.LifetimeSeconds) --[[@as number]]

  instance:SetLifetimeMode(lifetimeMode)
  instance.lifetime = lifetime * 1000

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param currentTime number
function CoinPickup:Update(currentTime)
  self:UpdateAnimation(currentTime)
end

---@return number
function CoinPickup:GetRadius()
  return self.radius
end

---@return number x, number y, number z
function CoinPickup:GetPosition()
  return self.entity:GetPosition()
end

function CoinPickup:UpdateAnimation(currentTime)
  local _, _, z = self.entity:GetPosition()
  local seconds = currentTime / 1000

  local offset = 0
  if self.bobFrequency ~= 0 and self.bobAmplitude > 0 then
    offset = math.sin(seconds * self.bobFrequency + self.randomOffset)
      * self.bobAmplitude
  end
  self.entity:SetPosition(nil, nil, z + offset):SetRotation(
    Util.Modulus(seconds * self.rotationSpeed * self.rotationDirection, 360)
  )
end

---Pickup logic
function CoinPickup:OnPickup()
  self:SetCollected(true)
  PlayerAddMoney(self.coin:GetValue())
  SoundPlay2D('Cash_Pickup')
  PickupSpeech.PlayMoney()
end

---Overwrite base method
---@return number
function CoinPickup:GetLifetime()
  return self.lifetime
end

---Overwrite base method
---@return integer
function CoinPickup:GetPed()
  return self.ped
end

---@return Coin
function CoinPickup:GetCoin()
  return self.coin
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.CoinPickup = CoinPickup

-- -------------------------------------------------------------------------- --
-- File: core/objects/pickup/PickupManager.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local Event = KNOCKOUT_COINS.Enum.Event
local Util = KNOCKOUT_COINS.Util

-- -------------------------------------------------------------------------- --
-- PickupManager Class                                                        --
-- -------------------------------------------------------------------------- --

---@class PickupManager
---@field private _eventManager EventManager
---@field pickups table<PickupManager_ID, PickupManager_Pickup>
local PickupManager = {}
PickupManager.__index = PickupManager

local nextId = 1

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param eventManager EventManager
---@return PickupManager
function PickupManager.new(eventManager)
  local instance = setmetatable({}, PickupManager)
  instance._eventManager = eventManager
  instance.pickups = {}
  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param pickup BasePickup|CoinPickup
function PickupManager:Register(pickup)
  self.pickups[nextId] = pickup
  nextId = nextId + 1
end

---@param id PickupManager_ID
---@param reason? string # for event
---@return boolean success
function PickupManager:Remove(id, reason)
  local pickup = self.pickups[id]
  if not pickup then return false end
  pickup:Destroy()
  self.pickups[id] = nil

  self._eventManager:Emit(Event.CoinRemoved, pickup, reason)

  if Util.GetGameEdition() == 'PS2' then collectgarbage() end

  return true
end

function PickupManager:RemoveAll()
  for id, pickup in pairs(self.pickups) do
    pickup:Destroy()
    self.pickups[id] = nil
  end
  self._eventManager:Emit(Event.AllCoinsCleared)
end

function PickupManager:Update()
  local now = GetTimer()
  local currentArea = AreaGetVisible()

  self._eventManager:Emit(Event.BeforeCoinUpdateAll)

  for id, _ in pairs(self.pickups) do
    self._eventManager:Emit(Event.BeforeCoinUpdate)

    self:UpdatePickup(id, now, currentArea)

    self._eventManager:Emit(Event.AfterCoinUpdate)
  end

  self._eventManager:Emit(Event.AfterCoinUpdateAll)
end

---@param id integer
---@param now number
---@param currentArea integer
function PickupManager:UpdatePickup(id, now, currentArea)
  local pickup = self.pickups[id]
  if not pickup then return end

  if pickup:IsCollected() then return end

  local MAX_UPDATE_DISTANCE = 50

  local px, py, pz = PlayerGetPosXYZ()
  local x, y, z = pickup:GetPosition()
  local distance = DistanceBetweenCoords3d(px, py, pz + 0.5, x, y, z)

  -- pickup collection logic
  if distance <= pickup:GetRadius() then
    pickup:OnPickup()

    if pickup:GetType() == 'coin' then
      local coin = (pickup --[[@as CoinPickup]]):GetCoin()
      local value = coin:GetValue()
      self._eventManager:Emit(Event.CoinCollected, pickup, coin, value)
    end

    return self:Remove(id, 'collected')
  end

  -- animation update logic (optimized)
  if pickup:GetEntity():GetArea() == currentArea then
    if Util.GetGameEdition() == 'SE' then
      local cx, cy, cz = CameraGetXYZ()
      distance = DistanceBetweenCoords3d(cx, cy, cz, x, y, z)
    else
      distance = DistanceBetweenCoords3d(px, py, pz, x, y, z)
    end

    if distance <= MAX_UPDATE_DISTANCE then
      pickup:Update(pickup:GetType() == 'coin' and now or nil)
    end
  end

  -- lifetime management logic
  if pickup:GetLifetimeMode() == 0 then -- time-based
    if pickup:GetAge() >= pickup:GetLifetime() then
      self._eventManager:Emit(Event.CoinExpired, pickup, pickup:GetAge())
      self:Remove(id, 'expired')
    end
    --
  elseif pickup:GetLifetimeMode() == 1 then -- ped-based
    if not PedIsValid(pickup:GetPed()) then self:Remove(id, 'invalidPed') end
    --
  elseif pickup:GetLifetimeMode() == 2 then -- hybrid
    local koTime = pickup:GetKOTime()
    if koTime and now - koTime >= pickup:GetLifetime() then
      self._eventManager:Emit(Event.CoinExpired, pickup, pickup:GetAge())
      self:Remove(id, 'expired')
    elseif not PedIsValid(pickup:GetPed()) and not koTime then
      pickup:SetKOTime(now)
    end
  end
end

---@return integer
function PickupManager:GetAllPickupsCount()
  local count = 0
  for _, _ in pairs(self.pickups) do
    count = count + 1
  end
  return count
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.PickupManager = PickupManager

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias PickupManager_ID integer
---@alias PickupManager_Pickup BasePickup|CoinPickup

-- -------------------------------------------------------------------------- --
-- File: core/coins/Coin.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Coin Class                                                                 --
-- -------------------------------------------------------------------------- --

---@class Coin
---@field value integer # in cents
---@field model Coin_ModelName
local Coin = {}
Coin.__index = Coin

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@param model? Coin_ModelName
---@param value? integer
---@return Coin
function Coin.new(model, value)
  local instance = setmetatable({}, Coin)
  instance.model = model or 'coin_penny'
  instance.value = value or 25
  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@return integer
function Coin:GetValue()
  return self.value
end

---@return Coin_ModelName
function Coin:GetModel()
  return self.model
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.Coin = Coin

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias Coin_ModelName 'coin_penny'|'coin_dollar'

-- -------------------------------------------------------------------------- --
-- File: core/coins/CoinDropManager.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local Default = KNOCKOUT_COINS.DefaultSettings
local Util = KNOCKOUT_COINS.Util

-- -------------------------------------------------------------------------- --
-- CoinDropManager Class                                                      --
-- -------------------------------------------------------------------------- --

---@class CoinDropManager
local CoinDropManager = {}

-- -------------------------------------------------------------------------- --
-- Static Methods                                                             --
-- -------------------------------------------------------------------------- --

---@param factionId integer
---@return integer count
function CoinDropManager.GetDropCountForFaction(factionId)
  local config = KNOCKOUT_COINS.GetSingleton():GetConfig()

  local name = Util.GetFactionName(factionId)
  local minKey = name .. 'Min'
  local maxKey = name .. 'Max'

  local minVal = config:Get(minKey, Default[minKey] or 1) --[[@as number]]
  local maxVal = config:Get(maxKey, Default[maxKey] or 2) --[[@as number]]

  if maxVal < minVal then maxVal = minVal end
  return math.random(minVal, maxVal)
end

---@return boolean
function CoinDropManager.ShouldDropCoin()
  local config = KNOCKOUT_COINS.GetSingleton():GetConfig()
  local globalChance = config:Get('GlobalDropChance', 75) --[[@as number]]
  return Util.PercentChance(globalChance)
end

---@return Coin_ModelName
function CoinDropManager.GetCoinType()
  local config = KNOCKOUT_COINS.GetSingleton():GetConfig()
  local pennyChance = config:Get('CoinPennyChance', Default.CoinPennyChance) --[[@as number]]
  local dollarChance = config:Get('CoinDollarChance', Default.CoinDollarChance) --[[@as number]]

  local roll = math.random(0, 100)
  if roll < pennyChance then
    return 'coin_penny'
  elseif roll < pennyChance + dollarChance then
    return 'coin_dollar'
  end
  return 'coin_penny'
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.CoinDropManager = CoinDropManager

-- -------------------------------------------------------------------------- --
-- File: core/threads/PedKnockedOut.lua
-- -------------------------------------------------------------------------- --
local KC = _G.KNOCKOUT_COINS
local Util = KC.Util

-- -------------------------------------------------------------------------- --
-- PedKnockedOut thread                                                       --
-- -------------------------------------------------------------------------- --
-- The function name MUST not be too long < 30 characters or it'll crash.

---@param eventManager? EventManager
function KC__PedKnockedOut(eventManager)
  KC__PedKnockedOut = nil --[[@diagnostic disable-line]]

  while not SystemIsReady() or AreaIsLoading() do
    Wait(0)
  end

  local gameEdition = Util.GetGameEdition()

  do
    local extraWaitTime = ({ ['SE'] = 500, ['AE'] = 3000, ['PS2'] = 3000 })[gameEdition]
    Wait(extraWaitTime or 3000)

    -- Bully AE: Wait for warning message
    if gameEdition == 'AE' and not KC.AE_isConfigLoaded then
      while KC.AE_isWarningMessageDisplayed do
        Wait(0)
      end
      Wait(1000)
    end
  end

  eventManager = eventManager or KC.GetSingleton():GetEventManager()

  local allPeds = gameEdition ~= 'SE' and Util.AllPeds or AllPeds
  local deadPeds = {}
  local waitTime = gameEdition == 'PS2' and 500 or 0

  gameEdition = nil --[[@diagnostic disable-line]]

  while true do
    Wait(waitTime) -- prevent PS2 thread overload

    for ped in allPeds() do
      if ped ~= gPlayer then
        if PedIsDead(ped) and not deadPeds[ped] then
          deadPeds[ped] = true
          eventManager:Emit('PedKnockedOut', ped)
        elseif not PedIsDead(ped) and deadPeds[ped] then
          deadPeds[ped] = nil -- revive/reset case
        end
      end
    end
  end
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KC.Thread.PedKnockedOut = KC__PedKnockedOut

-- -------------------------------------------------------------------------- --
-- Create the thread                                                          --
-- -------------------------------------------------------------------------- --

function KnockoutCoins_CreateThread()
  if KC.Util.GetGameEdition() ~= 'SE' then
    KC.Thread.PedKnockedOut_thread =
      CreateThread('KC__PedKnockedOut', KC.GetSingleton():GetEventManager())
  end
  KnockoutCoins_CreateThread = nil --[[@diagnostic disable-line]]
end

-- -------------------------------------------------------------------------- --
-- File: core/threads/ThreadManager.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- ThreadManager Class                                                        --
-- -------------------------------------------------------------------------- --

---@class ThreadManager
---@field private _threads table<string, { thread: thread, func: function }>
local ThreadManager = {}
ThreadManager.__index = ThreadManager

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@return ThreadManager
function ThreadManager.new()
  local instance = {}

  -- private attributes

  instance._threads = {}

  instance = setmetatable(instance, ThreadManager)

  -- public attributes
  -- ...

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param name string
---@param func function
---@param thread? thread # Already created thread
---@param ... any
function ThreadManager:Create(name, func, thread, ...)
  if self._threads[name] then return print('Thread already exists') end

  local l_thread = (KNOCKOUT_COINS.Util.GetGameEdition() ~= 'SE' and thread)
      and thread
    or CreateThread(func, unpack(arg))

  self._threads[name] = { thread = l_thread, func = func }
end

---@param name string
---@return boolean success
function ThreadManager:Stop(name)
  local entry = self._threads[name]
  if not entry then return false end
  TerminateThread(entry.thread)
  self._threads[name] = nil
  return true
end

function ThreadManager:StopAll()
  for _, entry in pairs(self._threads) do
    TerminateThread(entry.thread)
  end
  self._threads = {}
end

---@param name string
---@return ThreadManager_Entry
function ThreadManager:GetThreadEntry(name)
  return self._threads[name]
end

---@return string[]
function ThreadManager:GetThreadNameList()
  local list = {}
  for name, _ in pairs(self._threads) do
    table.insert(list, name)
  end

  table.sort(list, function(a, b)
    return a < b -- sort names by ascending
  end)

  return list
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.ThreadManager = ThreadManager

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias ThreadManager_Entry { thread: thread, func: function }

-- -------------------------------------------------------------------------- --
-- File: core/EventManager.lua
-- -------------------------------------------------------------------------- --
local isBullySE = KNOCKOUT_COINS.Util.GetGameEdition() == 'SE'

-- -------------------------------------------------------------------------- --
-- EventManager Class                                                         --
-- -------------------------------------------------------------------------- --

---@class EventManager
---@field private _prefix 'KnockoutCoins:'
---@field private _events table<string, EventManager_EventEntry[]>
local EventManager = {}
EventManager.__index = EventManager

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@return EventManager
function EventManager.new()
  local instance = {}

  -- Private attributes

  instance._prefix = 'KnockoutCoins:'
  instance._events = {}

  instance = setmetatable(instance, EventManager)

  -- Public attributes

  -- ...

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param eventName string
---@param callback function
function EventManager:AddListener(eventName, callback)
  if not self._events[eventName] then self._events[eventName] = {} end

  local entry
  if isBullySE then
    entry = {
      handler = RegisterLocalEventHandler(self._prefix .. eventName, callback),
      callback = callback,
    }
  else
    entry = { handler = nil, callback = callback }
  end

  table.insert(self._events[eventName], entry)
end

---@param eventName string
---@param callback? function
---@param handler? userdata
---@return boolean success
function EventManager:RemoveListener(eventName, callback, handler)
  if not self._events[eventName] then return false end
  if not callback and not handler then return false end

  for index, entry in ipairs(self._events[eventName]) do
    if entry.callback == callback or entry.handler == handler then
      if isBullySE then RemoveEventHandler(entry.handler) end
      table.remove(self._events[eventName], index)
      return true
    end
  end

  return false
end

---@param eventName string
---@param ... any
function EventManager:Emit(eventName, ...)
  if not self._events[eventName] then return end
  if isBullySE then
    RunLocalEvent(self._prefix .. eventName, unpack(arg))
  else
    for _, entry in ipairs(self._events[eventName]) do
      entry.callback(unpack(arg))
    end
  end
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.EventManager = EventManager

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias EventManager_EventEntry { handler: userdata, callback: function }

-- -------------------------------------------------------------------------- --
-- File: core/KnockoutCoins.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local Event = KNOCKOUT_COINS.Enum.Event
local Default = KNOCKOUT_COINS.DefaultSettings
local Util = KNOCKOUT_COINS.Util
local Thread = KNOCKOUT_COINS.Thread

local Coin = KNOCKOUT_COINS.Class.Coin
local CoinDropManager = KNOCKOUT_COINS.Class.CoinDropManager
local CoinPickup = KNOCKOUT_COINS.Class.CoinPickup
local Config = KNOCKOUT_COINS.Class.Config
local EventManager = KNOCKOUT_COINS.Class.EventManager
local IniSource = KNOCKOUT_COINS.Class.IniSource
local LuaSource = KNOCKOUT_COINS.Class.LuaSource
local ObjectEntity = KNOCKOUT_COINS.Class.ObjectEntity
local PickupManager = KNOCKOUT_COINS.Class.PickupManager
local ThreadManager = KNOCKOUT_COINS.Class.ThreadManager

-- -------------------------------------------------------------------------- --
-- KnockoutCoins Class                                                        --
-- -------------------------------------------------------------------------- --

---@class KnockoutCoins
---@field config Config
---@field eventManager EventManager
---@field pickupManager PickupManager
---@field threadManager ThreadManager
---@field spawnCoinLogic function
local KnockoutCoins = {}
KnockoutCoins.__index = KnockoutCoins

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@return KnockoutCoins
function KnockoutCoins.new()
  local instance = setmetatable({}, KnockoutCoins)

  local configData = KNOCKOUT_COINS.ConfigData
  local configSource

  if Util.GetGameEdition() == 'SE' then
    configSource = IniSource.new(configData.SE.path, configData.SE.file)
  else
    configSource = LuaSource.new(
      configData.AE.path,
      configData.AE.file,
      KNOCKOUT_COINS.Config or KNOCKOUT_COINS.DefaultSettings -- user config or default config
    )
  end

  instance.config = Config.new(KNOCKOUT_COINS.DefaultSettings, configSource)

  instance.eventManager = EventManager.new()
  instance.pickupManager = PickupManager.new(instance.eventManager)
  instance.threadManager = ThreadManager.new()

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

function KnockoutCoins:Init()
  ---@param ped integer
  function self.spawnCoinLogic(ped)
    local shouldDrop = Util.IsPedHumanoid(ped)
      and CoinDropManager.ShouldDropCoin()

    if not shouldDrop then
      return self.eventManager:Emit(Event.CoinDropFailed, ped)
    end

    local fx, fy, fz = PedGetPosXYZ(ped) -- feet
    local hx, hy, hz = PedGetHeadPos(ped) -- head
    local cx, cy, cz = Util.LerpBetweenCoords3d(fx, fy, fz, hx, hy, hz, 0.5)
    local zOffset = 0.5

    local factionId = PedGetFaction(ped)
    local numCoins = CoinDropManager.GetDropCountForFaction(factionId)
    local maxScatterDistance = 1

    for _ = 1, numCoins do
      local coinType = CoinDropManager.GetCoinType()
      local key = coinType == 'coin_penny' and 'CoinPenny' or 'CoinDollar'
      local fallbackValue = Default[key]
        or (math.random(2) == 1 and 'CoinPenny' or 'CoinDollar')

      local dx = ((math.random() - 0.5) * 2) * maxScatterDistance
      local dy = ((math.random() - 0.5) * 2) * maxScatterDistance

      local value = self.config:Get(key, fallbackValue) --[[@as number]]
      local coin = Coin.new(coinType, value)
      local object = ObjectEntity.new(coinType, cx + dx, cy + dy, cz + zOffset)
      local coinPickup = CoinPickup.new(object, coin, ped)
      self.pickupManager:Register(coinPickup)

      self.eventManager:Emit(Event.CoinSpawned, coinPickup, ped)
    end

    self.eventManager:Emit(Event.CoinBatchSpawned, ped, numCoins)
  end

  self.eventManager:AddListener('PedKnockedOut', self.spawnCoinLogic)

  local thread = Util.GetGameEdition() ~= 'SE'
      and KNOCKOUT_COINS.Thread.PedKnockedOut_thread
    or nil

  self.threadManager:Create(
    'PedKnockedOut',
    Thread.PedKnockedOut,
    thread,
    self.eventManager
  )
end

function KnockoutCoins:Update()
  self.pickupManager:Update()
end

function KnockoutCoins:Cleanup()
  self.pickupManager:RemoveAll()
  self.eventManager:RemoveListener('PedKnockedOut', self.spawnCoinLogic, nil)
  self.threadManager:StopAll()
end

-- -------------------------------------------------------------------------- --
-- Getting instance                                                           --
-- -------------------------------------------------------------------------- --

---@return Config
function KnockoutCoins:GetConfig()
  return self.config
end

---@return EventManager
function KnockoutCoins:GetEventManager()
  return self.eventManager
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.KnockoutCoins = KnockoutCoins

-- -------------------------------------------------------------------------- --
-- File: setup.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local KC = KNOCKOUT_COINS -- shorten
local KnockoutCoins = KC.Class.KnockoutCoins

-- -------------------------------------------------------------------------- --
-- Setup                                                                      --
-- -------------------------------------------------------------------------- --

---@return KnockoutCoins
function KNOCKOUT_COINS.GetSingleton()
  if not KC.Instance.knockoutCoins then
    KC.Instance.knockoutCoins = KnockoutCoins.new()
  end
  return KC.Instance.knockoutCoins
end

-- -------------------------------------------------------------------------- --
-- File: API.lua
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
-- Knockout Coins API                                                         --
-- -------------------------------------------------------------------------- --

local API = KNOCKOUT_COINS.API

-- -------------------------------------------------------------------------- --
-- Getting Instance                                                           --
-- -------------------------------------------------------------------------- --

---@return KnockoutCoins
function API.GetSingleton()
  return _G.KNOCKOUT_COINS.GetSingleton()
end

---@return EventManager
function API.GetEventManager()
  return API.GetEventManager()
end

-- TODO: Add more...

---@return integer
function API.GetSpawnedCoinCount()
  return API.GetSingleton().pickupManager:GetAllPickupsCount()
end
