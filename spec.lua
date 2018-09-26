require 'busted'

local function length(t)
  local len = 0
  for _, _ in pairs(t) do
    len = len + 1
  end
  return len
end

describe('Jonasbros:', function()
  local Jonas

  before_each(function()
    Jonas = require 'jonasbros'()
  end)

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
      factory({pos = 200})
      Jonas:update(2)

      local expectedError = 'Tried to create new tween from closed Factory.'
      assert.has_error(function() factory({pos = 50}) end, expectedError)
    end)
  end)

  describe('Test some internal shit', function()
    it('entities should be removed from factory once their tweens are done', function()
      local factory = Jonas
        :to(2, {pos = 100}, 'linear')

      factory({pos = 0})
      assert.same(1, length(factory._objects))

      Jonas:update(1)
      assert.same(1, length(factory._objects))

      factory({pos = 200})
      assert.same(2, length(factory._objects))

      Jonas:update(1)
      assert.same(1, length(factory._objects))

      Jonas:update(1)
      assert.same(0, length(factory._objects))
    end)

    it('committed factories should be closed and removed from Jonas', function()
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
  end)
end)
