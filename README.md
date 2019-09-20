# jonasbros

[![Build Status](https://travis-ci.org/oniietzschan/jonasbros.svg?branch=master)](https://travis-ci.org/oniietzschan/jonasbros)
[![Codecov](https://codecov.io/gh/oniietzschan/jonasbros/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/jonasbros)
![Lua](https://img.shields.io/badge/Lua-JIT%2C%205.1%2C%205.2-blue.svg)

Jonasbros is a tweening library for lua. It is designed to be efficient when dealing with thousands of objects which are using the exact same tween.

Check run the `main.lua` demo in LÖVE to see this in action.

![Example GIF](https://i.imgur.com/0RQhLM8.gif)

```lua
local Jonas = require 'jonasbros'()
local tween = Jonas
  -- 1. Color to Yellow,  Slow down to speed = 0
  :to(1.0, {r = 1, g = 1, b = 0, speed = 0},  'linear')
  -- 2. Color to Magenta, Stay at speed = 0
  :to(0.5, {r = 1, g = 0, b = 1, speed = 0},  'linear')
  -- 3. Color to Teal,    Speed up to speed = 10
  :to(2.0, {r = 0, g = 1, b = 1, speed = 25}, 'linear')

local circles = {}
for i = 1, 1024 do
  circles[i] = {
    x = 0, y = 0,
    speed = 15,
    angle = math.random() * math.pi * 2,
    r = 0, g = 0, b = 1, -- Color starts at Blue
  }
  tween(circles[i]) -- Apply our tween to this circle.
end
```

## Example

```lua
-- Create an object with some attributes that you wish to manipulate with your tween.
local objectA = {x = 0, y = 0}

-- Create your tween
local Jonas = require 'jonasbros'()
local tweenFactory = Jonas
  :to(1, {x = 50, y = 50}, 'linear')
  :to(2, {x = 150, y = 0}, 'linear')

-- Apply your tween to your object
tweenFactory(objectA)

-- Call Jonas:update(dt) to progress your tweens.
Jonas:update(0.25) -- objectA: x = 12.5, y = 12.5
Jonas:update(0.50) -- objectA: x = 37.5, y = 37.5

-- You can apply your tween to additional objects at any time.
local objectB = {x = 0, y = 100}
tweenFactory(object)
Jonas:update(0.5) -- objectA: x = 62.5, y = 43.75
--                   objectB: x = 25,   y = 75

-- Once you are done adding objects to your tween, call tweenFactory:commit()
-- Then, once all objects have finished their executing their tween, Jonas will forget about tweenFactory.
local objectC = {x = -50, y = -50}
tweenFactory(objectC)
tweenFactory:commit()
Jonas:update(3) -- objectA: x = 150, y = 0
--                 objectB: x = 150, y = 0
--                 objectC: x = 150, y = 0
-- All objects have finished tweening, so Jonas discards tweenFactory internally.
```
