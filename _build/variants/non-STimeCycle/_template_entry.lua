-- -------------------------------------------------------------------------- --
-- File: main.lua
-- -------------------------------------------------------------------------- --
local isBullyAE = type(_G.PlayerGetUsingTouchScreen) == 'function'
local isBullySE = not isBullyAE and type(_G.ClassMusicSetPlayers) == 'function'
local isBullyPS2 = not isBullyAE and not isBullySE

-- -------------------------------------------------------------------------- --
-- Setup                                                                      --
-- -------------------------------------------------------------------------- --

if isBullySE then
  function MissionSetup()
    while not SystemIsReady() or AreaIsLoading() do
      Wait(0)
    end

    LoadScript('init.lua')
    LoadScript('setup.lua')
    LoadScript('API.lua')
  end
end

-- -------------------------------------------------------------------------- --
-- Entry Point                                                                --
-- -------------------------------------------------------------------------- --

(function()
  function KnockoutCoins_main()
    KnockoutCoins_main = nil --[[@diagnostic disable-line]]

    while not isBullySE and (not SystemIsReady() or AreaIsLoading()) do
      Wait(0)
    end

    local mod = KNOCKOUT_COINS.GetSingleton()
    if KnockoutCoins_CreateThread then KnockoutCoins_CreateThread() end
    mod:Init()

    if isBullyPS2 then collectgarbage() end

    while true do
      Wait(0)
      mod:Update()
    end

    if not isBullySE then mod:Cleanup() end
  end

  CreateThread('KnockoutCoins_main')
end)()

-- -------------------------------------------------------------------------- --
-- Cleanup                                                                    --
-- -------------------------------------------------------------------------- --

if isBullySE then
  function MissionCleanup()
    KNOCKOUT_COINS.GetSingleton():Cleanup()
  end
end

-- -------------------------------------------------------------------------- --
-- Credit                                                                     --
-- -------------------------------------------------------------------------- --

function KnockoutCoins_Credit()
  print([[
    Knockout Coins
    Mod by: RBS ID

    GitHub: github.com/RanggaBS
    YouTube: youtube.com/@rbsid
  ]])
end
