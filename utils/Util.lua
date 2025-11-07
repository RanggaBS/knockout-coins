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
