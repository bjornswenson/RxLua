local Observable = require 'observable'

--- Returns a new Observable that completes when the specified Observable fires.
-- @arg {Observable} other - The Observable that triggers completion of the original.
-- @returns {Observable}
function Observable:takeUntil(other)
  return Observable.create(function(observer)
    local subscription
    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onCompleted()
      if subscription then subscription:unsubscribe() end
      return observer:onCompleted()
    end

    other:subscribe(onCompleted, onCompleted, onCompleted)

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
