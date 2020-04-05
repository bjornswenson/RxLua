local Subject = require 'subject'
local Subscription = require 'subscription'
local util = require 'util'

--- Returns a new Subject that serializes incoming events and processes them in the order received.
-- This is useful for subjects whose subscriptions self-destruct under certain conditions, as is the
-- case with a `takeUntil` or `takeWhile` operator.
-- @returns {Subject}
function Subject:serialize()
  local sourceSubject = self
  local serializedSubject = Subject.create()

  local queue = {locked = false}

  local function drainQueue()
    if not queue.locked then
      queue.locked = true
      while queue[1] do
        local func = table.remove(queue, 1)
        func()
      end
      queue.locked = false
    end
  end

  local function enqueueFunc(func)
    table.insert(queue, func)
    drainQueue()
  end

  function serializedSubject:subscribe(onNext, onError, onCompleted)
    local sourceSubscription = nil

    enqueueFunc(function()
      sourceSubscription = sourceSubject:subscribe(onNext, onError, onCompleted)
    end)

    return Subscription.create(function()
      enqueueFunc(function()
        sourceSubscription:unsubscribe()
       end)
    end)
  end

  function serializedSubject:onNext(...)
    local values = util.pack(...)
    enqueueFunc(function() sourceSubject:onNext(util.unpack(values)) end)
  end

  function serializedSubject:onError(message)
    enqueueFunc(function() sourceSubject:onError(message) end)
  end

  function serializedSubject:onCompleted()
    enqueueFunc(function() sourceSubject:onCompleted() end)
  end

  return serializedSubject
end
