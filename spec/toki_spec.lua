describe('Toki:', function()
  local Toki

  before_each(function()
    Toki = require 'toki'()
  end)

  describe('When creating an "after" timer.', function()
    it(':after() should work when provided arguments', function()
      local entity = {value = 'unchanged'}
      local duration = 1
      local callback = function(obj, newValue) obj.value = newValue end
      Toki:after(duration, callback, entity, 'changed')

      Toki:update(0.5)
      assert.same('unchanged', entity.value)
      Toki:update(0.5)
      assert.same('changed', entity.value)
      Toki:update(0.5)
      assert.same('changed', entity.value)
    end)

    it(':after() should work when not provided arguments', function()
      local testValue = false
      Toki:after(1, function(obj, newValue) testValue = true end)

      Toki:update(0.5)
      assert.same(false, testValue)
      Toki:update(0.5)
      assert.same(true, testValue)
      Toki:update(0.5)
      assert.same(true, testValue)
    end)

    it('chaining together :after() should work', function()
      local entity = {value = 'initial'}
      local callbackA = function(obj, newValue) obj.value = newValue end
      local callbackB = function(obj) obj.value = 'third' end
      Toki
        :after(1, callbackA, entity, 'first')
        :after(2, callbackA, entity, 'second')
        :after(3, callbackB, entity)

      Toki:update(0.5) -- 0.5
      assert.same('initial', entity.value)
      Toki:update(1) -- 1.5
      assert.same('first', entity.value)
      Toki:update(1) -- 2.5
      assert.same('first', entity.value)
      Toki:update(2) -- 4.5
      assert.same('second', entity.value)
      Toki:update(1) -- 5.5
      assert.same('second', entity.value)
      Toki:update(0.5) -- 6
      assert.same('third', entity.value)
      Toki:update(660) -- 666
      assert.same('third', entity.value)
    end)

    it('chaining together :after() should work with large time values', function()
      local entity = {value = 'initial'}
      local callback = function(obj, newValue) obj.value = newValue end
      Toki
        :after(1, callback, entity, 'first')
        :after(1, callback, entity, 'second')

      Toki:update(2)
      assert.same('second', entity.value)
    end)

    it(':to() should work even with a duration of 0.', function()
      local callback = function(obj) obj.value = true end

      local objectA = {value = false}
      Toki:after(0, callback, objectA)
      Toki:update(1)
      assert.same(true, objectA.value)

      local objectB = {value = false}
      Toki:after(0, callback, objectB)
      Toki:update(0)
      assert.same(true, objectB.value)
    end)

    it('new timers should not be updated in the same Toki:update() call which created them', function()
      local function callback(obj, i)
        obj.value = i
        Toki:after(i * 0.1, callback, obj, i + 1)
      end

      local object = {value = 0}
      Toki:after(0.1, callback, object, 1)
      Toki:update(1)
      assert.same(1, object.value)
      Toki:update(1)
      assert.same(2, object.value)
    end)
  end)

  describe('When :cancel()-ing a timer', function()
    it(':cancel() should work on a brand new timer', function()
      local entity = {value = false}
      local callback = function(obj) obj.value = true end
      local timer = Toki:after(1, callback, entity)

      Toki:cancel(timer)
      Toki:update(1)
      assert.same(false, entity.value)
    end)

    it(':cancel() should work on an in-progress timer', function()
      local entityA = {value = false}
      local entityB = {value = 'first'}
      local callback = function(obj, newValue) obj.value = newValue end
      local timerA = Toki:after(2, callback, entity)
      local timerB = Toki
        :after(1, callback, entityB, 'second')
        :after(1, callback, entityB, 'third')


      Toki:update(1.5)
      assert.same(false, entityA.value)
      assert.same('second', entityB.value)
      Toki:cancel(timerA)
      Toki:cancel(timerB)
      Toki:update(1)
      assert.same(false, entityA.value)
      assert.same('second', entityB.value)
    end)

    it(':cancel() should error on a finished timer', function()
      local entity = {value = false}
      local callback = function() end
      local timer = Toki:after(1, callback)

      Toki:update(1)

      local expectedError = tostring(timer) ..' is not in this pool.'
      assert.has_error(function() Toki:cancel(timer) end, expectedError)
    end)
  end)

  describe('Error checking', function()
    it('Should error error when calling :after() with invalid duration', function()
      local expectedError = 'duration must be a number, got: doug'
      local fn = function() end
      assert.has_error(function() Toki:after('doug', fn) end, expectedError)
    end)

    it('Should error error when calling :after() with invalid callback', function()
      local expectedError = 'callback must be a function, got: doug'
      assert.has_error(function() Toki:after(1, 'doug') end, expectedError)
    end)
  end)

  describe('Test some internal shit', function()
    it('entities should be removed from factory once their tweens are done', function()
      local fn = function() end
      Toki:after(1, fn)
      Toki:after(2, fn)
      Toki
        :after(2, fn)
        :after(1, fn)

      assert.same(3, Toki._timers.count)
      Toki:update(1)
      assert.same(2, Toki._timers.count)
      Toki:update(1)
      assert.same(1, Toki._timers.count)
      Toki:update(1)
      assert.same(0, Toki._timers.count)
    end)
  end)
end)
