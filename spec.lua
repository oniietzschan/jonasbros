require 'busted'

local Jonas = require 'jonasbros'

describe('Jonasbros:', function()
  -- before_each(function()
  -- end)

  describe('When tweening', function()
    it('Calling extendEnvironment() should add additional values to environment table', function()

      local tweenFactory = Jonas
        :to(2, {pos = 100}, 'linear')

      local entity = {pos = 0}
      local tweenHandle = tweenFactory(entity)

      Jonas:update(0.5)
      assert.same(25, entity.pos)
      Jonas:update(0.5)
      assert.same(50, entity.pos)
      Jonas:update(0.8)
      assert.same(90, entity.pos)
      Jonas:update(0.2)
      assert.same(100, entity.pos)
    end)
  end)
end)
