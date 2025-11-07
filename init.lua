-- -------------------------------------------------------------------------- --
-- Mod root global variable                                                   --
-- -------------------------------------------------------------------------- --

_G.KNOCKOUT_COINS = {
  API = {},
  Enum = {},
  Class = {},
  Instance = {},
  Util = {},
  Thread = {},
  DefaultSettings = {},

  -- Bully AE user configurations, `nil` by default
  ---@type table<string, boolean|number|string>?
  Config = nil,

  ConfigData = {
    SE = {
      path = 'config/',
      file = 'config_se.ini',
    },
    AE = {
      path = '/storage/emulated/0/Games/BullyAE/Mods/KnockoutCoins/config/',
      file = 'config_ae.lur',
    },
  },
  AE_isConfigLoaded = false,
  AE_isWarningMessageDisplayed = true,
}

-- -------------------------------------------------------------------------- --
-- Load scripts                                                               --
-- -------------------------------------------------------------------------- --

local isBullySE = type(_G.ClassMusicSetPlayers) == 'function'
  and type(_G.PlayerGetUsingTouchScreen) ~= 'function'

if isBullySE then
  local files = {
    { name = 'Util', dir = 'utils/' },
    { name = '_group', dir = 'enums/' },

    { name = 'BaseSource', dir = 'core/config/source/' },
    { name = 'IniSource', dir = 'core/config/source/' },
    { name = 'LuaSource', dir = 'core/config/source/' },
    { name = 'Config', dir = 'core/config/' },

    { name = 'ObjectEntity', dir = 'core/objects/' },
    { name = 'PickupSpeech', dir = 'core/objects/pickup/' },
    { name = 'BasePickup', dir = 'core/objects/pickup/' },
    { name = 'CoinPickup', dir = 'core/objects/pickup/' },
    { name = 'PickupManager', dir = 'core/objects/pickup/' },

    { name = 'Coin', dir = 'core/coins/' },
    { name = 'CoinDropManager', dir = 'core/coins/' },

    { name = 'PedKnockedOut', dir = 'core/threads/' },
    { name = 'ThreadManager', dir = 'core/threads/' },

    { name = 'EventManager', dir = 'core/' },
    { name = 'KnockoutCoins', dir = 'core/' },
  }
  for _, file in ipairs(files) do
    LoadScript(file.dir .. file.name .. '.lua')
  end
end

-- -------------------------------------------------------------------------- --
-- Default Settings                                                           --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.DefaultSettings = {
  -- [Coin Values]
  -- ------------------------------------------------------------------------ --
  -- Defines how much money each coin gives when collected.
  -- The game uses "cents" internally. (100 = $1.00)
  -- Example:
  --   25  = +$0.25
  --   100 = +$1.00
  -- ------------------------------------------------------------------------ --
  CoinPenny = 25, -- small gold coin (common)
  CoinDollar = 100, -- large silver coin (rare)

  -- [Coin Settings]
  -- ---------------------------------------------------------------------------- --
  -- Controls how coins behave after a ped is knocked out.
  -- ---------------------------------------------------------------------------- --

  -- Base chance (in percent) for *any* coin to drop.
  -- Individual coin chances are multiplied by this value.
  GlobalDropChance = 75,

  -- How close the player must be to automatically pick up a coin.
  PickupRadius = 1.25,

  -- Determines how long coins stay in the world before disappearing.
  --   0 = Time-based (coins vanish after `LifetimeSeconds`)
  --   1 = Ped-based (coins stay until the KO'd ped fades out)
  --   2 = Hybrid (stay while ped exists, then a short timer starts)
  LifetimeMode = 2,

  -- Duration (in seconds) coins remain if `LifetimeMode` = 0 or 2.
  LifetimeSeconds = 30,

  -- [Coin Type Chance]
  -- ---------------------------------------------------------------------------- --
  -- Defines individual drop chances for each coin type (percent).
  -- These chances are evaluated only if `GlobalDropChance` is passed.
  -- Example:
  --   CoinPennyChance = 80  -> 80% chance if a drop occurs
  --   CoinDollarChance = 20 -> 20% chance if a drop occurs
  -- ---------------------------------------------------------------------------- --
  CoinPennyChance = 80,
  CoinDollarChance = 20,

  -- [Coin Animation]
  -- ---------------------------------------------------------------------------- --
  -- Controls the visual animation and motion of dropped coins.
  -- ---------------------------------------------------------------------------- --

  -- Determines how high the coin bobs up and down.
  -- Default: 1
  BobAmplitude = 1,

  -- Determines how fast the coin bobs up and down.
  -- Higher values make it oscillate faster.
  -- Default: 3
  BobFrequency = 3,

  -- Determines how fast the coin spins in degrees per second.
  -- Default: 60
  RotationSpeed = 60,

  -- If true, each coin will spin in a random direction (clockwise or counterclockwise).
  -- If false, all coins spin the same direction.
  -- Default: true
  RandomRotationDirection = true,

  -- If true, all coins bob in sync (move up and down together).
  -- If false, each coin has a random phase offset.
  -- Default: false
  BobSync = false,

  -- [Faction Drop Amount]
  -- ---------------------------------------------------------------------------- --
  -- Defines how many coins each faction may drop when knocked out.
  -- The final number can be randomized between Min and Max.
  -- Example: NerdMin = 1, NerdMax = 3 → drop 1–3 coins randomly.
  -- ---------------------------------------------------------------------------- --

  PrefectMin = 1,
  PrefectMax = 2,

  NerdMin = 1,
  NerdMax = 2,

  JockMin = 1,
  JockMax = 2,

  DropoutMin = 1,
  DropoutMax = 2,

  GreaserMin = 1,
  GreaserMax = 2,

  PreppyMin = 2,
  PreppyMax = 4,

  StudentMin = 1,
  StudentMax = 2,

  CopMin = 1,
  CopMax = 3,

  TeacherMin = 1,
  TeacherMax = 3,

  TownpersonMin = 1,
  TownpersonMax = 3,

  ShopkeepMin = 1,
  ShopkeepMax = 4,

  BullyMin = 1,
  BullyMax = 2,
}
