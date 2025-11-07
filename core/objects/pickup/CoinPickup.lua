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
