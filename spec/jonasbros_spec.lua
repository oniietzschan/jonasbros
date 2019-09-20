require 'busted'

local function length(t)
  local len = 0
  for _, _ in pairs(t) do
    len = len + 1
  end
  return len
end

function assertFloatsEqual(a, b)
  return math.abs(a - b) < 0.0000000000001
end

describe('Jonasbros:', function()
  local Jonas

  before_each(function()
    Jonas = require 'jonasbros'()
  end)

  describe('When creating single tween', function()
    it(':to() should work correctly on 1 entity', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entity = {pos = 0}
      factory(entity)

      Jonas:update(0.5)
      assert.same(25, entity.pos)
      Jonas:update(0.5)
      assert.same(50, entity.pos)
      Jonas:update(0.8)
      assert.same(90, entity.pos)
      Jonas:update(0.2)
      assert.same(100, entity.pos)
    end)

    it('Should not be possible to overshoot tween', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entity = {pos = 0}
      factory(entity)

      Jonas:update(3)
      assert.same(100, entity.pos)
      Jonas:update(0.5)
      assert.same(100, entity.pos)
    end)

    it(':to() should work correctly on 2 entities', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entityA = {pos = 0}
      local entityB = {pos = 200}
      factory(entityA)
      factory(entityB)

      Jonas:update(1)
      assert.same(50, entityA.pos)
      assert.same(150, entityB.pos)
      Jonas:update(0.8)
      assert.same(90, entityA.pos)
      assert.same(110, entityB.pos)
      Jonas:update(0.2)
      assert.same(100, entityA.pos)
      assert.same(100, entityB.pos)
    end)

    it(':to() should work correctly on 2 entities added at different times', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entityA = {pos = 0}
      local entityB = {pos = 200}

      factory(entityA)
      Jonas:update(1)
      assert.same(50, entityA.pos)
      assert.same(200, entityB.pos)

      factory(entityB)
      Jonas:update(1)
      assert.same(100, entityA.pos)
      assert.same(150, entityB.pos)

      Jonas:update(1)
      assert.same(100, entityA.pos)
      assert.same(100, entityB.pos)
    end)

    -- it(':to() should work even with a duration of 0.', function()
    --   local factory = Jonas
    --     :to(0, {pos = 100}, 'linear')

    --   local entity = {pos = 0}
    --   factory(entity)

    --   Jonas:update(1)
    --   assert.same(100, entity.pos)
    -- end)

    -- This corner case is not handled well right now. Will not fix?
    -- it(':to() should work even with a duration of 0 and when updated with dt = 0.', function()
    --   local factory = Jonas
    --     :to(0, {pos = 100}, 'linear')

    --   local entity = {pos = 0}
    --   factory(entity)

    --   Jonas:update(0)
    --   assert.same(100, entity.pos)
    -- end)

    it(':new(), :to() should work correctly', function()
      local factory = Jonas:new()
      factory:to(2, {pos = 100}, 'linear')

      local entity = {pos = 0}
      factory(entity)

      Jonas:update(2)
      assert.same(100, entity.pos)
    end)
  end)

  describe('When using various easing functions', function()
    local entity
    local updateDeltaTime

    local function newFactoryWithEasing(easing)
      local factory = Jonas
        :to(1, {val = 1}, easing)
      entity = {val = 0}
      factory(entity)
    end

    local function updateAndAssert(expected)
      Jonas:update(updateDeltaTime)
      if assertFloatsEqual(expected, entity.val) == false then
        -- If tests are passing, then this line isn't reached, so exclude from coverage.
        -- luacov: disable
        assert.equal(expected, entity.val)
        -- luacov: enable
      end
    end

    before_each(function()
      entity = nil
      updateDeltaTime = 0.25
    end)

    it('linear should work as expected when defaulted to', function()
      newFactoryWithEasing()
      updateAndAssert(0.25)
      updateAndAssert(0.5)
      updateAndAssert(0.75)
      updateAndAssert(1)
    end)

    it('linear should work as expected when specified', function()
      newFactoryWithEasing('linear')
      updateAndAssert(0.25)
      updateAndAssert(0.5)
      updateAndAssert(0.75)
      updateAndAssert(1)
    end)

    it('quad-in should work as expected', function()
      newFactoryWithEasing('quad-in')
      updateAndAssert(0.0625)
      updateAndAssert(0.25)
      updateAndAssert(0.5625)
      updateAndAssert(1)
    end)

    it('quad-out should work as expected', function()
      newFactoryWithEasing('quad-out')
      updateAndAssert(0.4375)
      updateAndAssert(0.75)
      updateAndAssert(0.9375)
      updateAndAssert(1)
    end)

    it('quad-in-out should work as expected', function()
      newFactoryWithEasing('quad-in-out')
      updateAndAssert(0.125)
      updateAndAssert(0.5)
      updateAndAssert(0.875)
      updateAndAssert(1)
    end)

    it('quad-out-in should work as expected', function()
      newFactoryWithEasing('quad-out-in')
      -- I wrote *-out-in myself, so give it some extra testing.
      updateDeltaTime = 0.125
      updateAndAssert(0.21875)
      updateAndAssert(0.375)
      updateAndAssert(0.46875)
      updateAndAssert(0.5)
      updateAndAssert(0.53125)
      updateAndAssert(0.625)
      updateAndAssert(0.78125)
      updateAndAssert(1)
    end)

    it('cubic-in should work as expected', function()
      newFactoryWithEasing('cubic-in')
      updateAndAssert(0.015625)
      updateAndAssert(0.125)
      updateAndAssert(0.421875)
      updateAndAssert(1)
    end)

    it('quart-in should work as expected', function()
      newFactoryWithEasing('quart-in')
      updateAndAssert(0.00390625)
      updateAndAssert(0.0625)
      updateAndAssert(0.31640625)
      updateAndAssert(1)
    end)

    it('quint-in should work as expected', function()
      newFactoryWithEasing('quint-in')
      updateAndAssert(0.0009765625)
      updateAndAssert(0.03125)
      updateAndAssert(0.2373046875)
      updateAndAssert(1)
    end)

    it('sine-in should work as expected', function()
      newFactoryWithEasing('sine-in')
      updateAndAssert(0.076120467488713)
      updateAndAssert(0.29289321881345)
      updateAndAssert(0.61731656763491)
      updateAndAssert(1)
    end)

    it('circ-in should work as expected', function()
      newFactoryWithEasing('circ-in')
      updateAndAssert(0.031754163448146)
      updateAndAssert(0.13397459621556)
      updateAndAssert(0.33856217223385)
      updateAndAssert(1)
    end)

    it('back-in should work as expected', function()
      newFactoryWithEasing('back-in')
      updateAndAssert(-0.0641365625)
      updateAndAssert(-0.0876975)
      updateAndAssert(0.1825903125)
      updateAndAssert(1)
    end)

    it('elastic-in should work as expected', function()
      newFactoryWithEasing('elastic-in')
      updateAndAssert(-0.0055242717280199)
      updateAndAssert(-0.015625)
      updateAndAssert(0.088388347648318)
      updateAndAssert(1)
    end)

    it('bounce-in should work as expected', function()
      newFactoryWithEasing('bounce-in')
      -- Bounce is a fucking nightmare, so test more thoroughly.
      updateDeltaTime = 0.125
      updateAndAssert(0.1181640625)
      updateAndAssert(0.47265625)
      updateAndAssert(0.9697265625)
      updateAndAssert(0.765625)
      updateAndAssert(0.7978515625)
      updateAndAssert(0.97265625)
      updateAndAssert(0.9619140625)
      updateAndAssert(1)
    end)
  end)

  describe('When creating chained tweens', function()
    it(':to() should work correctly on 1 entity', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')
        :to(1, {pos = 50}, 'linear')
        :to(4, {pos = 250}, 'linear')

      local entity = {pos = 0}
      factory(entity)

      Jonas:update(1)
      assert.same(50, entity.pos)
      Jonas:update(1)
      assert.same(100, entity.pos)
      Jonas:update(0.5)
      assert.same(75, entity.pos)
      Jonas:update(0.5)
      assert.same(50, entity.pos)
      Jonas:update(1)
      assert.same(100, entity.pos)
      Jonas:update(1)
      assert.same(150, entity.pos)
      Jonas:update(2)
      assert.same(250, entity.pos)
      Jonas:update(100)
      assert.same(250, entity.pos)
    end)

    it(':to() should work correctly on 1 entity when updated with large value', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')
        :to(1, {pos = 50}, 'linear')
        :to(4, {pos = 250}, 'linear')

      local entity = {pos = 0}
      factory(entity)

      Jonas:update(7)
      assert.same(250, entity.pos)
    end)

    -- it(':to() should work even when one has a duration of 0.', function()
    --   local factory = Jonas
    --     :to(1, {pos = 100}, 'linear')
    --     :to(0, {pos = 200}, 'linear')
    --     :to(1, {pos = 300}, 'linear')

    --   local entityA = {pos = 0}
    --   factory(entityA)
    --   Jonas:update(1)
    --   assert.same(200, entityA.pos)
    --   Jonas:update(1)
    --   assert.same(300, entityA.pos)

    --   local entityB = {pos = 0}
    --   factory(entityB)
    --   Jonas:update(1.5)
    --   assert.same(250, entityB.pos)
    --   Jonas:update(0.5)
    --   assert.same(300, entityB.pos)
    -- end)
  end)

  describe('Error checking', function()
    it('Should error when trying to create factory with invalid tween parameters', function()
      local expectedError = 'tween goal must be a number, got: doug'
      assert.has_error(function() Jonas:to(2, {pos = 'doug'}, 'linear') end, expectedError)
    end)

    it('Should error when trying to add new tween to closed factory.', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')
      factory({pos = 0})
      factory:commit()
      -- So long as factory is still processing, you can actually still make more tweens. Might be confusing.
      factory({pos = 200})
      Jonas:update(2)

      local expectedError = 'Tried to create new tween from closed Factory.'
      assert.has_error(function() factory({pos = 50}) end, expectedError)
    end)

    it('Should error when creating tween with made up easing function.', function()
      local expectedError = 'Unknown easing function: doug-faster-in-out'
      assert.has_error(function() Jonas:to(2, {pos = 100}, 'doug-faster-in-out') end, expectedError)
    end)
  end)

  describe('Test some internal shit', function()
    it('entities should be removed from factory once their tweens are done', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      factory({pos = 0})
      assert.same(1, factory._tweens[1].pool.count)

      Jonas:update(1)
      assert.same(1, factory._tweens[1].pool.count)

      factory({pos = 200})
      assert.same(2, factory._tweens[1].pool.count)

      Jonas:update(1)
      assert.same(1, factory._tweens[1].pool.count)

      Jonas:update(1)
      assert.same(0, factory._tweens[1].pool.count)
    end)

    it('finished committed factories should be closed and removed from Jonas', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')
      assert.same(1, length(Jonas._factories))
      assert.same(false, factory._closed)

      factory({pos = 0})
      factory:commit()
      Jonas:update(1)
      assert.same(1, length(Jonas._factories))
      assert.same(false, factory._closed)

      Jonas:update(1)
      assert.same(0, length(Jonas._factories))
      assert.same(true, factory._closed)
    end)

    it('finished committed chained factories should be closed and removed from Jonas', function()
      local factory = Jonas
        :to(1, {pos = 100}, 'linear')
        :to(1, {pos = 200}, 'linear')
        :to(1, {pos = 300}, 'linear')

      assert.same(1, length(Jonas._factories))
      assert.same(false, factory._closed)

      factory({pos = 0})
      factory:commit()
      Jonas:update(1)
      Jonas:update(2)

      assert.same(0, length(Jonas._factories))
      assert.same(true, factory._closed)
    end)
  end)
end)
