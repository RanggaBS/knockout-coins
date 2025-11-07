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
