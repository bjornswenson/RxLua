local Observable = require 'observable'

--- Returns a new Observable that only produces the first n results of the original.
-- @arg {number=1} n - The number of elements to produce before completing.
-- @returns {Observable}
function Observable:take(n)
  n = n or 1

  return Observable.create(function(observer)
    local subscription
    if n <= 0 then
      observer:onCompleted()
      return
    end

    local i = 1

    local function onNext(...)
      observer:onNext(...)

      i = i + 1

      if i > n then
        if subscription then subscription:unsubscribe() end
        observer:onCompleted()
      end
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onCompleted()
      return observer:onCompleted()
    end

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
