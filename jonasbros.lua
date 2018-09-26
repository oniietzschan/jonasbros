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

Jonas.easing = {
  linear = function(p) return p end,
}

do
  -- This block of code is heavily based on some logic from rxi's flux library.
  -- https://github.com/rxi/flux
  -- Copyright © rxi, licensed under the MIT License
  -- Please do not make a lawsuit onegaishimasu.
  local easing = {
    quad    = "p * p",
    cubic   = "p * p * p",
    quart   = "p * p * p * p",
    quint   = "p * p * p * p * p",
    expo    = "2 ^ (10 * (p - 1))",
    sine    = "1 - math.cos(p * math.pi / 2)",
    circ    = "1 - math.sqrt(1 - p * p)",
    back    = "p * p * (2.70158 * p - 1.70158)",
    elastic = "-(2 ^ (10 * (p - 1)) * math.sin((p - 1.075) * (math.pi * 2) / .3))",
    -- Sorry. It's the same as hump.timer's bounce, I swear!
    bounce = [[math.min(
      7.5625 * p ^ 2,
      7.5625 * (p - 1.5   * (1 / 2.75)) ^ 2 + .75,
      7.5625 * (p - 2.25  * (1 / 2.75)) ^ 2 + .9375,
      7.5625 * (p - 2.625 * (1 / 2.75)) ^ 2 + .984375
    )]],
  }
  local variations = {
    ['-in'] = [[
      return $e
    ]],
    ["-out"] = [[
      p = 1 - p
      return 1 - ($e)
    ]],
    ["-in-out"] = [[
      p = p * 2
      if p < 1 then
        return .5 * ($e)
      else
        p = 2 - p
        return .5 * (1 - ($e)) + .5
      end
    ]],
    ["-out-in"] = [[
      p = p * 2
      if p < 1 then
        p = 1 - p
        return .5 * (1 - ($e))
      else
        p = p - 1
        return .5 * ($e) + .5
      end
    ]],
  }
  local loadstring = loadstring or load -- Lua 5.3 support.
  for k, expr in pairs(easing) do
    for suffix, template in pairs(variations) do
      local easingFn = loadstring("return function(p) " .. template:gsub("%$e", expr) .. " end")()
      Jonas.easing[k .. suffix] = easingFn
    end
  end
end

local Factory = {}
local FactoryMT

function Factory:init(jonas, ...)
  self._jonas = jonas
  self._jonas:add(self)
  self._tweens = {}
  self._committed = false
  self._closed = false
  return self
end

function Factory:to(duration, goals, ease)
  ease = ease or 'linear'
  assertType(duration, 'number', 'duration')
  assertType(goals,    'table',  'tween attribute goals')
  assertType(ease,     'string', 'easing function')

  local t = {
    rate = 1 / duration,
    goals = {},
    ease = Jonas.easing[ease],
    objects = {},
    objectCount = 0,
  }
  if t.ease == nil then
    error('Unknown easing function: ' .. ease)
  end
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
    -- Process tween.
    for object, objData in pairs(tween.objects) do
      -- Calculate progress.
      local progress = objData.progress + deltaProgress, 0
      -- Update attributes
      local easedProgress = tween.ease(math.min(1, progress))
      for attr, t in pairs(objData.attrs) do
        object[attr] = t.start + (t.diff * easedProgress)
      end
      -- Handle when tween is finished.
      if progress >= 1 then
        tween.objects[object] = nil
        tween.objectCount = tween.objectCount - 1
         -- Store delta-time remainder.
        advancing[object] = (progress - 1) / tween.rate
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
