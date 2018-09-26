local Jonas = require 'jonasbros'()

local START_SPEED = 100
local SECOND_SPEED = 250
local MAX_CIRCLES = 1024

local circles = {}
local circleIndex = 0
local tween = nil

function love.load()
  tween = Jonas
    :to(1.0, {r = 1, g = 1, b = 0, speed = 0}, 'linear') -- Slow down to speed = 0
    :to(0.5, {r = 1, g = 0, b = 1, speed = 0}, 'linear') -- Stay at speed = 0
    :to(2.0, {r = 0, g = 1, b = 1, speed = SECOND_SPEED}) -- Speed up to speed = 10
end

local function fromPolar(angle, len)
  return math.cos(angle) * len,
         math.sin(angle) * len
end

function love.update(dt)
  do -- Create new circle (or reuse the oldest one)
    circleIndex = (circleIndex % MAX_CIRCLES) + 1
    if circles[circleIndex] == nil then
      circles[circleIndex] = {}
    end
    local circle = circles[circleIndex]

    circle.angle = math.random() * math.pi * 2
    circle.speed = START_SPEED
    circle.r = 0
    circle.g = 0
    circle.b = 1
    local w, h = love.graphics.getDimensions()
    circle.x = w / 2
    circle.y = h / 2
    tween(circle)
  end

  -- Move all circles.
  for i, circle in ipairs(circles) do
    local dx, dy = fromPolar(circle.angle, circle.speed * dt)
    circle.x = circle.x + dx
    circle.y = circle.y + dy
  end

  -- Update all tweens.
  Jonas:update(dt)
end

function round(val, decimal)
  return math.floor( (val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
end

function love.draw()
  -- Draw circles.
  for i, circle in ipairs(circles) do
    love.graphics.setColor(circle.r, circle.g, circle.b)
    love.graphics.circle('fill', circle.x, circle.y, 5)
  end
  -- Print stats.
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Circles: ' .. #circles, 10, 10)
  local memKiB = collectgarbage('count')
  local memMiB = round(memKiB / 1024, 3)
  love.graphics.print('Memory: ' .. memMiB .. 'MiB', 10, 25)
end
