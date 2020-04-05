local Observable = require 'observable'
local Observer = require 'observer'
local Subscription = require 'subscription'
local util = require 'util'

--- @class Subject
-- @description Subjects function both as an Observer and as an Observable. Subjects inherit all
-- Observable functions, including subscribe. Values can also be pushed to the Subject, which will
-- be broadcasted to any subscribed Observers. If an observer subscribes after this Subject has
-- already completed or terminated in an error, the observer receives the onComplete() or onError()
-- event immediately and the subscription is cancelled.
local Subject = setmetatable({}, Observable)
Subject.__index = Subject
Subject.__tostring = util.constant('Subject')

--- Creates a new Subject.
-- @returns {Subject}
function Subject.create()
  local self = {
    observers = {},
    stopped = false,
    errorMessage = nil
  }

  return setmetatable(self, Subject)
end

--- Creates a new Observer and attaches it to the Subject.
-- @arg {function|table} onNext|observer - A function called when the Subject produces a value or
--                                         an existing Observer to attach to the Subject.
-- @arg {function} onError - Called when the Subject terminates due to an error.
-- @arg {function} onCompleted - Called when the Subject completes normally.
function Subject:subscribe(onNext, onError, onCompleted)
  local observer

  if util.isa(onNext, Observer) then
    observer = onNext
  else
    observer = Observer.create(onNext, onError, onCompleted)
  end

  if self.stopped then
    if self.errorMessage then
      observer:onError(self.errorMessage)
    else
      observer:onCompleted()
    end
    return Subscription.empty()
  end

  table.insert(self.observers, observer)

  return Subscription.create(function()
    for i = 1, #self.observers do
      if self.observers[i] == observer then
        table.remove(self.observers, i)
        return
      end
    end
  end)
end

--- Pushes zero or more values to the Subject. They will be broadcasted to all Observers.
-- @arg {*...} values
function Subject:onNext(...)
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:onNext(...)
    end
  end
end

--- Signal to all Observers that an error has occurred.
-- @arg {string=} message - A string describing what went wrong.
function Subject:onError(message)
  if not self.stopped then
    self.stopped = true
    self.errorMessage = message

    for i = #self.observers, 1, -1 do
      self.observers[i]:onError(message)
    end
  end
end

--- Signal to all Observers that the Subject will not produce any more values.
function Subject:onCompleted()
  if not self.stopped then
    self.stopped = true

    for i = #self.observers, 1, -1 do
      self.observers[i]:onCompleted()
    end

    self.observers = {}
  end
end

Subject.__call = Subject.onNext

return Subject
