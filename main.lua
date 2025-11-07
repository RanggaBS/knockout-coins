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

function main()
  while not isBullySE and (not SystemIsReady() or AreaIsLoading()) do
    Wait(0)
  end

  local mod = KNOCKOUT_COINS.GetSingleton()
  if KnockoutCoins_DebugThread then KnockoutCoins_DebugThread() end
  if KnockoutCoins_CreateThread then KnockoutCoins_CreateThread() end
  mod:Init()

  if isBullyPS2 then collectgarbage() end

  while true do
    Wait(0)
    mod:Update()
  end

  if not isBullySE then mod:Cleanup() end
end

-- -------------------------------------------------------------------------- --
-- Cleanup                                                                    --
-- -------------------------------------------------------------------------- --

if isBullySE then
  function MissionCleanup()
    KNOCKOUT_COINS.GetSingleton():Cleanup()
  end
end

-- -------------------------------------------------------------------------- --
-- Debug Thread                                                               --
-- -------------------------------------------------------------------------- --

function KnockoutCoins_DebugThread()
  local enableDebugThread = false

  if enableDebugThread then
    if isBullySE then
      CreateThread(function()
        while true do
          Wait(0)
          if IsKeyBeingPressed('P') then
            local x, y, z = PedGetOffsetInWorldCoords(gPlayer, 0, 1, 0)
            local randomPed = PedCreateXYZ(math.random(2, 258), x, y, z)
            Wait(50)
            PedFaceObjectNow(randomPed, gPlayer, 2)
            PedApplyDamage(randomPed, 99999)
          end
        end
      end)

    --
    else
      while not SystemIsReady() or AreaIsLoading() do
        Wait(0)
      end

      -- hide HUDs
      -- health bar, trouble meter bar, radar
      ToggleHUDComponentVisibility(0, false)
      ToggleHUDComponentVisibility(4, false)
      ToggleHUDComponentVisibility(11, false)
      ClockSet(16, 0) -- 4pm
      PauseGameClock()

      -- attire
      ClothingSetPlayersHair('R_SSmart_04')
      ClothingBuildPlayer()

      DisablePunishmentSystem(true)
    end
  end

  KnockoutCoins_DebugThread = nil --[[@diagnostic disable-line]]
end

-- -------------------------------------------------------------------------- --
-- Test Event                                                                 --
-- -------------------------------------------------------------------------- --

if isBullySE then
  --[[ CreateThread(function()
    -- local eventManager = KNOCKOUT_COINS.GetSingleton():GetEventManager()

    -- ✅
    -- eventManager:AddListener('PedKnockedOut', function(ped)
    --   print(PedGetName(ped) .. ' knocked out!')
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinSpawned', function(pickup, ped)
    --   print(pickup, ped)
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinBatchSpawned', function(ped, count)
    --   print(PedGetName(ped) .. ' dropped ' .. count .. ' coins!')
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinCollected', function(pickup, coin, value)
    --   print(
    --     'coin '
    --       .. coin:GetModel()
    --       .. ' collected from '
    --       .. PedGetName(pickup:GetPed())
    --   )
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinRemoved', function(pickup, reason)
    --   print(
    --     'coin '
    --       .. (pickup:GetCoin():GetModel())
    --       .. ' removed from '
    --       .. (PedGetName(pickup:GetPed()) or 'unknown') -- PedGetName returns nil because the ped already died/was removed
    --       .. ' because '
    --       .. reason
    --   )
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinExpired', function(pickup, age)
    --   print('coin was existent for' .. tostring(age / 1000) .. ' seconds')
    -- end)

    -- ✅
    -- eventManager:AddListener('CoinDropFailed', function(ped)
    --   print(PedGetName(ped) .. ' failed to drop coin')
    -- end)

    -- ⌛ not triggered because immediately loaded
    -- eventManager:AddListener('ConfigLoaded', function(config)
    --   print('config loaded')
    --   print(config:Get('BobSync'))
    -- end)
  end) ]]
end

-- -------------------------------------------------------------------------- --
-- Addon test - Magnetic Coin                                                 --
-- -------------------------------------------------------------------------- --

--[[if isBullySE then
  CreateThread(function()
    Wait(500)

    local CoinMagnetManager = {
      active = true,
      radius = 5.0, -- meter
      speed = 0.01, -- movement speed per update
      pickups = {}, ---@type CoinPickup[]
    }

    function CoinMagnetManager:Track(pickup)
      table.insert(self.pickups, pickup)
    end

    function CoinMagnetManager:Update()
      if not self.active then return end
      local px, py, pz = PlayerGetPosXYZ()
      pz = pz + 1

      for i, pickup in ipairs(self.pickups) do
        if pickup:IsExist() then
          local x, y, z = pickup:GetEntity():GetPosition()
          local dx, dy, dz = px - x, py - y, pz - z
          local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

          if dist < self.radius then
            -- normalize & move a bit closer
            local nx, ny, nz = dx / dist, dy / dist, dz / dist
            pickup:GetEntity():SetPosition(
              x + nx * self.speed,
              y + ny * self.speed,
              z + nz * self.speed
            )
          end
        else
          table.remove(self.pickups, i)
        end
      end
    end

    local eventManager = KNOCKOUT_COINS.GetSingleton():GetEventManager()

    eventManager:AddListener('CoinSpawned', function(pickup, ped)
      CoinMagnetManager:Track(pickup)
    end)

    eventManager:AddListener('BeforeCoinUpdateAll', function()
      CoinMagnetManager:Update()
    end)
  end)
end]]

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

-- -------------------------------------------------------------------------- --
-- STimeCycle                                                                 --
-- -------------------------------------------------------------------------- --
-- for AE and PS2

if isBullySE then return end

function F_AttendedClass()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    return
  end
  SetSkippedClass(false)
  PlayerSetPunishmentPoints(0)
end
function F_MissedClass()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    return
  end
  SetSkippedClass(true)
  StatAddToInt(166)
end
function F_AttendedCurfew()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrintString('You got home in time for curfew', 4)
  end
end
function F_MissedCurfew()
  if not PedInConversation(gPlayer) and not MissionActive() then
    TextPrint('TM_TIRED5', 4, 2)
  end
end
function F_StartClass()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    return
  end
  F_RingSchoolBell()
  local current_punishment = PlayerGetPunishmentPoints()
  current_punishment = current_punishment + GetSkippingPunishment()
end
function F_EndClass()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    return
  end
  F_RingSchoolBell()
end
function F_StartMorning()
  F_UpdateTimeCycle()
end
function F_EndMorning()
  F_UpdateTimeCycle()
end
function F_StartLunch()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    F_UpdateTimeCycle()
    return
  end
  F_UpdateTimeCycle()
end
function F_EndLunch()
  F_UpdateTimeCycle()
end
function F_StartAfternoon()
  F_UpdateTimeCycle()
end
function F_EndAfternoon()
  F_UpdateTimeCycle()
end
function F_StartEvening()
  F_UpdateTimeCycle()
end
function F_EndEvening()
  F_UpdateTimeCycle()
end
function F_StartCurfew_SlightlyTired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_Tired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_MoreTired()
  F_UpdateTimeCycle()
end
function F_StartCurfew_TooTired()
  F_UpdateTimeCycle()
end
function F_EndCurfew_TooTired()
  F_UpdateTimeCycle()
end
function F_EndTired()
  F_UpdateTimeCycle()
end
function F_Nothing() end
function F_ClassWarning()
  if
    IsMissionCompleated('3_08') and not IsMissionCompleated('3_08_PostDummy')
  then
    return
  end
  local warnchoice = math.random(1, 2)
end
function F_UpdateTimeCycle()
  if not IsMissionCompleated('1_B') then
    local CurrentDay = GetCurrentDay(false)
    if CurrentDay < 0 or 2 < CurrentDay then SetCurrentDay(0) end
  end
  F_UpdateCurfew()
end
function F_UpdateCurfew()
  local rules = shared.gCurfewRules or F_CurfewDefaultRules
  rules()
end
function F_CurfewDefaultRules()
  local timeHour = ClockGet()
  if 23 <= timeHour or timeHour < 7 then
    shared.gCurfew = true
  else
    shared.gCurfew = false
  end
end
