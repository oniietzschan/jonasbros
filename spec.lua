require 'busted'

local Jonas = require 'jonasbros'

describe('Jonasbros:', function()
  -- before_each(function()
  -- end)

  describe('When tweening', function()
    it(':to() should work correctly on 1 entity', function()

      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entity = {pos = 0}
      local tweenHandle = factory(entity)

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
      local tweenHandle = factory(entity)

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
  end)
end)
