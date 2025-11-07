local isBullySE = KNOCKOUT_COINS.Util.GetGameEdition() == 'SE'

-- -------------------------------------------------------------------------- --
-- EventManager Class                                                         --
-- -------------------------------------------------------------------------- --

---@class EventManager
---@field private _prefix 'KnockoutCoins:'
---@field private _events table<string, EventManager_EventEntry[]>
local EventManager = {}
EventManager.__index = EventManager

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@return EventManager
function EventManager.new()
  local instance = {}

  -- Private attributes

  instance._prefix = 'KnockoutCoins:'
  instance._events = {}

  instance = setmetatable(instance, EventManager)

  -- Public attributes

  -- ...

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param eventName string
---@param callback function
function EventManager:AddListener(eventName, callback)
  if not self._events[eventName] then self._events[eventName] = {} end

  local entry
  if isBullySE then
    entry = {
      handler = RegisterLocalEventHandler(self._prefix .. eventName, callback),
      callback = callback,
    }
  else
    entry = { handler = nil, callback = callback }
  end

  table.insert(self._events[eventName], entry)
end

---@param eventName string
---@param callback? function
---@param handler? userdata
---@return boolean success
function EventManager:RemoveListener(eventName, callback, handler)
  if not self._events[eventName] then return false end
  if not callback and not handler then return false end

  for index, entry in ipairs(self._events[eventName]) do
    if entry.callback == callback or entry.handler == handler then
      if isBullySE then RemoveEventHandler(entry.handler) end
      table.remove(self._events[eventName], index)
      return true
    end
  end

  return false
end

---@param eventName string
---@param ... any
function EventManager:Emit(eventName, ...)
  if not self._events[eventName] then return end
  if isBullySE then
    RunLocalEvent(self._prefix .. eventName, unpack(arg))
  else
    for _, entry in ipairs(self._events[eventName]) do
      entry.callback(unpack(arg))
    end
  end
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.EventManager = EventManager

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias EventManager_EventEntry { handler: userdata, callback: function }
