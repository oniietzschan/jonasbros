local Toki = {
  _VERSION     = 'toki v0.0.0',
  _URL         = 'https://github.com/oniietzschan/jonasbros',
  _DESCRIPTION = 'A timer library.',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 shru

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 【AS IZ】, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. PLEASE HAVE A FUN AND BE GENTLE WITH THIS SOFTWARE.
  ]],
}



---------------
-- UTILITIES --
---------------

-- Support Lua 5.3
local unpack = unpack or table.unpack

local EMPTY_TABLE = {}

local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end



-----------------
-- OBJECT POOL --
-----------------

local Pool = {}

function Pool:init()
  self.items = {}
  self._itemIndexes = {}
  self.count = 0
  return self
end

function Pool:add(item)
  if self._itemIndexes[item] then
    error('Already added ' .. tostring(item) .. ' to this pool.')
  end
  self.count = self.count + 1
  self.items[self.count] = item
  self._itemIndexes[item] = self.count
end

function Pool:remove(item)
  if self._itemIndexes[item] == nil then
    error(tostring(item) .. ' is not in this pool.')
  end
  local id = self._itemIndexes[item]
  local replacement = self.items[self.count]
  self._itemIndexes[replacement] = id
  self.items[id] = replacement
  self._itemIndexes[item] = nil
  self.items[self.count] = nil
  self.count = self.count - 1
end

function Pool:contains(item)
  return self._itemIndexes[item] ~= nil
end

local PoolMetatable = {__index = Pool}

local function newPool()
  return setmetatable({}, PoolMetatable)
    :init()
end



-----------
-- TIMER --
-----------

local Timer = {}

function Timer:_init()
  return self
end

function Timer:after(duration, callback, ...)
  assertType(duration, 'number', 'duration')
  assertType(callback, 'function', 'callback')
  local timerObj
  if self._duration == nil then
    timerObj = self
  else
    if self._next == nil then
      self._next = {nextIndex = 1}
    end
    timerObj = {}
    table.insert(self._next, timerObj)
  end
  timerObj._duration = duration
  timerObj._callback = callback
  timerObj._arguments = (select('#', ...) == 0) and EMPTY_TABLE or {...}
  return self
end

function Timer:update(dt)
  self._duration = self._duration - dt
  while self._duration <= 0 do
    self._callback(unpack(self._arguments))
    -- Return if no [remaining] chained timers.
    if self._next == nil or self._next.nextIndex > #self._next then
      self.done = true
      return
    end
    local t = self._next[self._next.nextIndex]
    self._next.nextIndex = self._next.nextIndex + 1
    self._duration = self._duration + t._duration -- add instead of replace, so that remainder is included.
    self._callback = t._callback
    self._arguments = t._arguments
  end
end

local TimerMT = {
  __index = Timer,
}



----------
-- TOKI --
----------

function Toki:_init()
  self._timers = newPool()
  self._toUpdate = {}
  return self
end

function Toki:after(...)
  return self
    :_newTimer()
    :after(...)
end

function Toki:_newTimer()
  local timer = setmetatable({}, TimerMT)
    :_init(self)
  self._timers:add(timer)
  return timer
end

function Toki:update(dt)
  -- Clone self._timers.items into self._toUpdate
  for i, timer in ipairs(self._timers.items) do
    self._toUpdate[i] = timer
  end
  -- Iterate through self._toUpdate backwards, removing as we go
  for i = #self._toUpdate, 1, -1 do
    local timer = self._toUpdate[i]
    self._toUpdate[i] = nil
    timer:update(dt)
    if timer.done then
      self._timers:remove(timer)
    end
  end
end

function Toki:cancel(timer)
  self._timers:remove(timer)
end

local TokiMT = {
  __index = Toki,
}

return function()
  return setmetatable({}, TokiMT)
    :_init()
end
