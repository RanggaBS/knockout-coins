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
