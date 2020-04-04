local Subject = require 'subjects/subject'
local Observer = require 'observer'
local util = require 'util'

--- @class BehaviorSubject
-- @description A Subject that tracks its current value. Provides an accessor to retrieve the most
-- recent pushed value, and all subscribers immediately receive the latest value.
local BehaviorSubject = setmetatable({}, Subject)
BehaviorSubject.__index = BehaviorSubject
BehaviorSubject.__tostring = util.constant('BehaviorSubject')

--- Creates a new BehaviorSubject.
-- @arg {*...} value - The initial values.
-- @returns {BehaviorSubject}
function BehaviorSubject.create(...)
  local self = {
    observers = {},
    stopped = false
  }

  if select('#', ...) > 0 then
    self.value = util.pack(...)
  end

  return setmetatable(self, BehaviorSubject)
end

--- Creates a new Observer and attaches it to the BehaviorSubject. Immediately broadcasts the most
-- recent value to the Observer.
-- @arg {function} onNext - Called when the BehaviorSubject produces a value.
-- @arg {function} onError - Called when the BehaviorSubject terminates due to an error.
-- @arg {function} onCompleted - Called when the BehaviorSubject completes normally.
function BehaviorSubject:subscribe(onNext, onError, onCompleted)
  local observer

  if util.isa(onNext, Observer) then
    observer = onNext
  else
    observer = Observer.create(onNext, onError, onCompleted)
  end

  if not self.stopped and self.value then
    observer:onNext(util.unpack(self.value))
  end

  return Subject.subscribe(self, observer)
end

--- Pushes zero or more values to the BehaviorSubject. They will be broadcasted to all Observers.
-- @arg {*...} values
function BehaviorSubject:onNext(...)
  if not self.stopped then
    self.value = util.pack(...)
  end
  return Subject.onNext(self, ...)
end

--- Pushes an error message to all Observers and terminates the subject. Clears the current value
-- causing `getValue()` to return `nil`.
-- @arg {string} message
function BehaviorSubject:onError(message)
  self.value = nil
  return Subject.onError(self, message)
end

--- Completes the subject and terminates its event stream. Clears the current value, causing
-- `getValue()` to return `nil`.
function BehaviorSubject:onCompleted()
  self.value = nil
  return Subject.onCompleted(self)
end

--- Returns the last value emitted by the BehaviorSubject, or the initial value passed to the
-- constructor if nothing has been emitted yet.
-- @returns {*...}
function BehaviorSubject:getValue()
  if self.value ~= nil then
    return util.unpack(self.value)
  end
end

BehaviorSubject.__call = BehaviorSubject.onNext

return BehaviorSubject
