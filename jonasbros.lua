local Jonas = {
  _VERSION     = 'jonasbros v0.0.0',
  _URL         = 'https://github.com/oniietzschan/jonasbros',
  _DESCRIPTION = 'A tweening library.',
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
  ]]
}

Jonas._factories = {}

local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end

local Factory = {}

local function _linearFn(p) return p end

function Factory:init(timer, duration, goals, ease)
  self._timer = timer
  self._rate = 1 / duration
  self._goals = {}
  for k, v in pairs(goals) do
    assertType(v, 'number', 'tween goal')
    self._goals[k] = v
  end
  self._ease = _linearFn
  self._objects = {}
  self._objectCount = 0
  return self
end

function Factory:__call(object)
  local t = {
    progress = 0,
    attrs = {}
  }
  for attr, goal in pairs(self._goals) do
    t.attrs[attr] = {
      start = object[attr],
      diff = goal - object[attr],
    }
  end
  self._objects[object] = t
  self._objectCount = self._objectCount + 1
end

function Factory:update(dt)
  local deltaProgress = (self._rate * dt)
  for object, objData in pairs(self._objects) do
    objData.progress = math.min(objData.progress + deltaProgress, 1)
    local easedProgress = self._ease(objData.progress)
    for attr, t in pairs(objData.attrs) do
      object[attr] = t.start + (t.diff * easedProgress)
    end
    -- Handle when tween is finished.
    if objData.progress == 1 then
      self._objects[object] = nil
      self._objectCount = self._objectCount - 1
    end
  end
end

local FactoryMT = {
  __index = Factory,
  __call = Factory.__call,
}

function Jonas:to(...)
  local factory = setmetatable({}, FactoryMT)
    :init(self, ...)
  self._factories[factory] = true
  return factory
end

function Jonas:update(dt)
  for factory, _ in pairs(self._factories) do
    factory:update(dt)
  end
end

return Jonas
