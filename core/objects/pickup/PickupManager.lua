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
