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
