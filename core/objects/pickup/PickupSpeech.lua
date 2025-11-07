-- -------------------------------------------------------------------------- --
-- PickupSpeech Class                                                         --
-- -------------------------------------------------------------------------- --

---@class PickupSpeech
---@field private _lastPlayTime number
---@field private _cooldown number
local PickupSpeech = {
  _lastPlayTime = 0,
  _cooldown = 3000, -- in milliseconds
}

-- -------------------------------------------------------------------------- --
-- Static Methods                                                             --
-- -------------------------------------------------------------------------- --

---@return boolean
function PickupSpeech.CanPlaySpeech()
  local JIMMY_MODEL_ID = 0
  if not PedIsModel(gPlayer, JIMMY_MODEL_ID) then return false end

  local self = PickupSpeech

  local now = GetTimer()
  if now - self._lastPlayTime < self._cooldown then return false end
  self._lastPlayTime = now

  return true
end

---@param speechName string
function PickupSpeech.Play(speechName)
  local self = PickupSpeech
  if not self.CanPlaySpeech() then return end
  if SoundSpeechPlaying(gPlayer) then SoundStopCurrentSpeechEvent(gPlayer) end
  SoundPlayAmbientSpeechEvent(gPlayer, speechName)
end

function PickupSpeech.PlayMoney()
  local self = PickupSpeech
  self.Play('PLAYER_GET_MONEY')
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.PickupSpeech = PickupSpeech
