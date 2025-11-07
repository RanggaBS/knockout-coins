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
