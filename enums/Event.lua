-- -------------------------------------------------------------------------- --
-- Event Enumeration                                                          --
-- -------------------------------------------------------------------------- --

---@enum EEvent
local Event = {
  AllCoinsCleared = 'AllCoinsCleared',
  CoinBatchSpawned = 'CoinBatchSpawned',
  CoinCollected = 'CoinCollected',
  CoinDropFailed = 'CoinDropFailed',
  CoinExpired = 'CoinExpired',
  CoinRemoved = 'CoinRemoved',
  CoinSpawned = 'CoinSpawned',
  PedKnockedOut = 'PedKnockedOut',

  BeforeCoinUpdate = 'BeforeCoinUpdate',
  AfterCoinUpdate = 'AfterCoinUpdate',

  BeforeCoinUpdateAll = 'BeforeCoinUpdateAll',
  AfterCoinUpdateAll = 'AfterCoinUpdateAll',
}

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Enum.Event = Event
