-- -------------------------------------------------------------------------- --
-- Import                                                                     --
-- -------------------------------------------------------------------------- --

local KC = KNOCKOUT_COINS -- shorten
local KnockoutCoins = KC.Class.KnockoutCoins

-- -------------------------------------------------------------------------- --
-- Setup                                                                      --
-- -------------------------------------------------------------------------- --

---@return KnockoutCoins
function KNOCKOUT_COINS.GetSingleton()
  if not KC.Instance.knockoutCoins then
    KC.Instance.knockoutCoins = KnockoutCoins.new()
  end
  return KC.Instance.knockoutCoins
end
