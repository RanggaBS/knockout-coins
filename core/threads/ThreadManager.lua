-- -------------------------------------------------------------------------- --
-- ThreadManager Class                                                        --
-- -------------------------------------------------------------------------- --

---@class ThreadManager
---@field private _threads table<string, { thread: thread, func: function }>
local ThreadManager = {}
ThreadManager.__index = ThreadManager

-- -------------------------------------------------------------------------- --
-- Constructor                                                                --
-- -------------------------------------------------------------------------- --

---@return ThreadManager
function ThreadManager.new()
  local instance = {}

  -- private attributes

  instance._threads = {}

  instance = setmetatable(instance, ThreadManager)

  -- public attributes
  -- ...

  return instance
end

-- -------------------------------------------------------------------------- --
-- Methods                                                                    --
-- -------------------------------------------------------------------------- --

---@param name string
---@param func function
---@param thread? thread # Already created thread
---@param ... any
function ThreadManager:Create(name, func, thread, ...)
  if self._threads[name] then return print('Thread already exists') end

  local l_thread = (KNOCKOUT_COINS.Util.GetGameEdition() ~= 'SE' and thread)
      and thread
    or CreateThread(func, unpack(arg))

  self._threads[name] = { thread = l_thread, func = func }
end

---@param name string
---@return boolean success
function ThreadManager:Stop(name)
  local entry = self._threads[name]
  if not entry then return false end
  TerminateThread(entry.thread)
  self._threads[name] = nil
  return true
end

function ThreadManager:StopAll()
  for _, entry in pairs(self._threads) do
    TerminateThread(entry.thread)
  end
  self._threads = {}
end

---@param name string
---@return ThreadManager_Entry
function ThreadManager:GetThreadEntry(name)
  return self._threads[name]
end

---@return string[]
function ThreadManager:GetThreadNameList()
  local list = {}
  for name, _ in pairs(self._threads) do
    table.insert(list, name)
  end

  table.sort(list, function(a, b)
    return a < b -- sort names by ascending
  end)

  return list
end

-- -------------------------------------------------------------------------- --
-- Export                                                                     --
-- -------------------------------------------------------------------------- --

KNOCKOUT_COINS.Class.ThreadManager = ThreadManager

-- -------------------------------------------------------------------------- --
-- Types                                                                      --
-- -------------------------------------------------------------------------- --

---@alias ThreadManager_Entry { thread: thread, func: function }
