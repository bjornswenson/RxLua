local util = require 'util'

--- @class CompositeSubscription
-- @description A composed set of subscriptions that enables convenient subscription management
-- and easy unsubscribing.
local CompositeSubscription = {}
CompositeSubscription.__index = CompositeSubscription
CompositeSubscription.__tostring = util.constant('CompositeSubscription')

--- Creates a new CompositeSubscription.
-- @arg {Subscriptions...} subscriptions - A set of subscriptions to initialize the object with.
-- @returns {CompositeSubscription}
function CompositeSubscription.create(...)
  local self = {
    subscriptions = {...},
  }

  return setmetatable(self, CompositeSubscription)
end

--- Adds the given Subscriptions to this object.
-- @returns {nil}
function CompositeSubscription:add(...)
  for _,subscription in ipairs({...}) do
    table.insert(self.subscriptions, subscription)
  end
end

--- Unsubscribes all registered subscriptions and removes them from this CompositeSubscription.
-- @returns {nil}
function CompositeSubscription:unsubscribe()
  for _,subscription in ipairs(self.subscriptions) do
    subscription:unsubscribe()
  end
  self.subscriptions = {}
end