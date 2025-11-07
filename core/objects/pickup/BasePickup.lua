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
