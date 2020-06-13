local Observable = require 'observable'
local util = require 'util'

--- Returns a new Observable that produces the first value of the original that satisfies a
-- predicate.
-- @arg {function} predicate - The predicate used to find a value.
function Observable:find(predicate)
  predicate = predicate or util.identity

  return Observable.create(function(observer)
    local subscription

    local function onNext(...)
      util.tryWithObserver(observer, function(...)
        if predicate(...) then
          observer:onNext(...)
          if subscription then subscription:unsubscribe() end
          return observer:onCompleted()
        end
      end, ...)
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onCompleted()
      return observer:onCompleted()
    end

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
