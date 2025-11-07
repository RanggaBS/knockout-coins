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
