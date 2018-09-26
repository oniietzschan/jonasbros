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

local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end

local Factory = {}
local FactoryMT

local function _linearFn(p) return p end

function Factory:init(jonas, ...)
  self._jonas = jonas
  self._jonas:add(self)
  self._tweens = {}
  self._committed = false
  self._closed = false
  return self
end

function Factory:to(duration, goals, ease)
  local t = {
    rate = 1 / duration,
    goals = {},
    ease = _linearFn,
    objects = {},
    objectCount = 0,
  }
  for k, v in pairs(goals) do
    assertType(v, 'number', 'tween goal')
    t.goals[k] = v
  end
  table.insert(self._tweens, t)
  return self
end

function Factory:__call(object)
  if self._closed then
    error('Tried to create new tween from closed Factory.')
  end
  self:_addToTween(1, object)
end

function Factory:update(dt)
  local advancing = {}
  for i, tween in ipairs(self._tweens) do
    local deltaProgress = (tween.rate * dt)
    -- Add advancing elements
    for object, remainder in pairs(advancing) do
      self:_addToTween(i, object)
      tween.objects[object].progress = (remainder * tween.rate) - deltaProgress
      advancing[object] = nil
    end
    -- process tween.
    for object, objData in pairs(tween.objects) do
      -- Calculate progress.
      local progress, remainder = objData.progress + deltaProgress, 0
      if progress > 1 then
        remainder = (progress - 1) / tween.rate
        progress = 1
      end
      -- Update attributes
      local easedProgress = tween.ease(progress)
      for attr, t in pairs(objData.attrs) do
        object[attr] = t.start + (t.diff * easedProgress)
      end
      -- Handle when tween is finished.
      if progress == 1 then
        tween.objects[object] = nil
        tween.objectCount = tween.objectCount - 1
        advancing[object] = remainder
      else
        objData.progress = progress
      end
    end
  end
end

function Factory:_addToTween(i, object)
  local tween = self._tweens[i]
  local t = {
    progress = 0,
    attrs = {}
  }
  for attr, goal in pairs(tween.goals) do
    t.attrs[attr] = {
      start = object[attr],
      diff = goal - object[attr],
    }
  end
  tween.objects[object] = t
  tween.objectCount = tween.objectCount + 1
end

function Factory:commit()
  self._committed = true
  return self
end

function Factory:isFinished()
  for _, c in ipairs(self._tweens) do
    if c.objectCount >= 1 then
      return false
    end
  end
  return true
end

function Factory:close()
  self._closed = true
end

FactoryMT = {
  __index = Factory,
  __call = Factory.__call,
}

function Jonas:to(...)
  return self
    :new()
    :to(...)
end

function Jonas:new()
  return setmetatable({}, FactoryMT)
    :init(self)
end

function Jonas:add(factory)
  self._factories[factory] = true
  return self
end

function Jonas:update(dt)
  for factory, _ in pairs(self._factories) do
    factory:update(dt)
    if factory:isFinished() then
      factory:close()
      self._factories[factory] = nil
    end
  end
end

local JonasMT = {
  __index = Jonas,
}

return function()
  local t = {
    _factories = {},
  }
  return setmetatable(t, JonasMT)
end
